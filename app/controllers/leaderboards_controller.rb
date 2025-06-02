class LeaderboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.group
      @group   = current_user.group
      @cycle   = current_cycle_for(@group)   # picks today's cycle (or latest)

      if @cycle
        @players   = @group.users
        @rankings  = calculate_rankings(@players, @cycle)
      else
        flash.now[:alert] = "No active cycle for your group."
      end
    end

    # social leaderboard stays as-is
    @social_rankings = calculate_social_rankings(User.all)
  end

  def social
    @players = User.all
    @social_rankings = calculate_social_rankings(@players)
    # @matches = Match.where(cycle_id: nil).where.not(winner_id: nil)
    # # Build stats: each user's wins in social matches
    # @rankings = User.joins("JOIN matches ON (matches.winner_id = users.id)")
    #                 .where("matches.cycle_id IS NULL")
    #                 .group("users.id")
    #                 .order("COUNT(matches.id) DESC")
                    # .select("users.*, COUNT(matches.id) as wins")
  end

  private

  def current_cycle_for(group)
    today = Date.current
    group.cycles.find_by("start_date <= ? AND end_date >= ?", today, today) ||
      group.cycles.order(start_date: :desc).first
  end

  # --- ranking for ONE cycle ----------------------------------------
  def calculate_rankings(players, cycle)
    rankings = players.map do |player|
      {
        player: player,
        wins: cycle_matches(cycle)
                .where(winner_id: player.id)
                .count,

        matches_played: cycle_matches(cycle)
                          .where("player1_id = :id OR player2_id = :id", id: player.id)
                          .where.not(winner_id: nil)
                          .count
      }
    end

    rankings.sort_by { |r| [-r[:wins],
                            -head_to_head_wins(r[:player], players, cycle)] }
  end

  def group_cycle_matches(group)
    Match.joins(:cycle).where(cycles: { group_id: group.id })
  end

  def head_to_head_wins(player, players, cycle)
    players.sum do |opponent|
      next 0 if player == opponent

      cycle_matches(cycle)
        .where(winner_id: player.id)
        .where("(player1_id = :opp AND player2_id = :me) OR
                (player1_id = :me  AND player2_id = :opp)",
               me: player.id, opp: opponent.id)
        .count
    end
  end

  def calculate_social_rankings(players)
    rankings = players.map do |player|
      {
        player: player,
        wins: Match.where(winner: player, cycle_id: nil).count,
        matches_played: Match.where(cycle_id: nil)
                             .where("player1_id = ? OR player2_id = ?", player.id, player.id)
                             .where.not(winner_id: nil)
                             .count
      }
    end

    # If you want to incorporate a head-to-head tiebreaker as well, you can:
    rankings.sort_by { |r| [-r[:wins], -social_head_to_head_wins(r[:player], players)] }
    # Otherwise, just sort by total wins descending:
    # rankings.sort_by { |r| -r[:wins] }
  end


  # (Optional) If you want to maintain a similar tie-breaker structure:
  def social_head_to_head_wins(player, players)
    players.sum do |opponent|
      next 0 if opponent == player
      # number of times player beat opponent in social matches
      Match.where(cycle_id: nil, winner_id: player.id)
           .where(player1_id: opponent.id).or(
             Match.where(cycle_id: nil, winner_id: player.id)
                  .where(player2_id: opponent.id)
           ).count
    end
  end
end
