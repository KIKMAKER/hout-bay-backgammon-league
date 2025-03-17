class LeaderboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @players = current_user.group.users
    @rankings = calculate_rankings(@players)
  end

  def social
    @matches = Match.where(cycle_id: nil).where.not(winner_id: nil)
    # Build stats: each user's wins in social matches
    @rankings = User.joins("JOIN matches ON (matches.winner_id = users.id)")
                    .where("matches.cycle_id IS NULL")
                    .group("users.id")
                    .order("COUNT(matches.id) DESC")
                    .select("users.*, COUNT(matches.id) as wins")
  end

  private

  def calculate_rankings(players)
    rankings = players.map do |player|
      {
        player: player,
        wins: Match.where(winner: player).count,
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
end
