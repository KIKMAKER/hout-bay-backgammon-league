module Admin
  class StatsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    def index
      all_matches = Match.includes(:player1, :player2, :winner).all
      completed   = all_matches.where.not(winner_id: nil)

      @total_matches  = all_matches.count
      @total_players  = User.count
      @social_matches = all_matches.where(cycle_id: nil).count
      @competitive_matches = all_matches.where.not(cycle_id: nil).count

      # First and most recent match dates
      @first_match = all_matches.order(:match_date).first
      @latest_match = all_matches.order(match_date: :desc).first

      # Champion: most wins
      winner_counts = completed.group(:winner_id).count
      if winner_counts.any?
        top_winner_id = winner_counts.max_by { |_, v| v }&.first
        @champion = User.find_by(id: top_winner_id)
        @champion_wins = winner_counts[top_winner_id]
      end

      # Most active player: most matches played
      player_match_counts = {}
      all_matches.each do |m|
        player_match_counts[m.player1_id] = (player_match_counts[m.player1_id] || 0) + 1
        player_match_counts[m.player2_id] = (player_match_counts[m.player2_id] || 0) + 1
      end
      if player_match_counts.any?
        top_active_id = player_match_counts.max_by { |_, v| v }&.first
        @most_active = User.find_by(id: top_active_id)
        @most_active_count = player_match_counts[top_active_id]
      end

      # Best win rate (minimum 3 completed matches)
      win_rates = {}
      User.all.each do |user|
        played = completed.where("player1_id = :id OR player2_id = :id", id: user.id).count
        next if played < 3
        wins = completed.where(winner_id: user.id).count
        win_rates[user] = (wins.to_f / played * 100).round(1)
      end
      if win_rates.any?
        @win_rate_leader = win_rates.max_by { |_, v| v }&.first
        @win_rate = win_rates[@win_rate_leader]
      end

      # Biggest margin of victory
      scored = all_matches.where.not(player1_score: nil).where.not(player2_score: nil)
      if scored.any?
        @biggest_margin_match = scored.sort_by { |m| (m.player1_score - m.player2_score).abs }.last
        @biggest_margin = (@biggest_margin_match.player1_score - @biggest_margin_match.player2_score).abs
      end

      # Most prolific rivalry: pair with most matches
      rivalry_counts = {}
      all_matches.each do |m|
        pair = [m.player1_id, m.player2_id].sort
        rivalry_counts[pair] = (rivalry_counts[pair] || 0) + 1
      end
      if rivalry_counts.any?
        top_pair = rivalry_counts.max_by { |_, v| v }&.first
        @rival1 = User.find_by(id: top_pair[0])
        @rival2 = User.find_by(id: top_pair[1])
        @rivalry_count = rivalry_counts[top_pair]
      end

      # Total points scored across all matches
      @total_points = scored.sum("player1_score + player2_score")
    end

    private

    def authorize_admin!
      redirect_to root_path, alert: "Unauthorized" unless current_user.admin?
    end
  end
end
