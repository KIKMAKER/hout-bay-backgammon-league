class LeaderboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.group
      @group   = current_user.group
      @players = @group.users
      @rankings = calculate_rankings(@players, @group)   # pass the group in
    end

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

  def calculate_rankings(players, group)
    rankings = players.map do |player|
      {
        player: player,
        wins:   group_cycle_matches(group)
               .where(winner_id: player.id)
               .count,

        matches_played: group_cycle_matches(group)
                        .where("player1_id = :id OR player2_id = :id", id: player.id)
                        .where.not(winner_id: nil)
                        .count
      }
    end

    # Sort by wins, then by head-to-head record
    rankings.sort_by { |r| [-r[:wins], -head_to_head_wins(r[:player], players, group)] }
  end

  def group_cycle_matches(group)
    Match.joins(:cycle).where(cycles: { group_id: group.id })
  end

  def head_to_head_wins(player, players, group)
    players.sum do |opponent|
      next 0 if player == opponent
      group_cycle_matches(group)
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
