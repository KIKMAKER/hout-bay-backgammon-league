class LeaderboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    unless current_user.group.nil?
      @players = current_user.group.users
      @rankings = calculate_rankings(@players)
    end
    @social_players = User.all
    @social_rankings = calculate_social_rankings(@social_players)
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

  def calculate_rankings(players)
    rankings = players.map do |player|
      {
        player: player,
        wins: Match.where(winner_id: player.id).count,
        matches_played: Match.where("player1_id = ? OR player2_id = ?", player.id, player.id).where.not(winner_id: nil).count
      }
    end

    # Sort by wins, then by head-to-head record
    rankings.sort_by { |r| [-r[:wins], -head_to_head_wins(r[:player], players)] }
  end

  def head_to_head_wins(player, players)
    players.sum do |opponent|
      next 0 if player == opponent

      Match.where(winner: player, player1: opponent).or(Match.where(winner: player, player2: opponent)).count
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
