class LeaderboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.group
      @group   = current_user.group
      @cycle   = @group.cycles.order(start_date: :desc).first   # picks today's cycle (or latest)
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

  # def current_cycle_for(group)
  #   today = Date.current
  #   group.cycles.find_by("start_date <= ? AND end_date >= ?", today, today) ||
  #     group.cycles.order(start_date: :desc).first
  # end

  # --- ranking for ONE cycle ----------------------------------------
  def calculate_rankings(players, cycle)
    # Calculate base stats
    rankings = players.map do |player|
      {
        player: player,
        wins: cycle_matches(cycle).where(winner_id: player.id).count,
        matches_played: cycle_matches(cycle)
                          .where("player1_id = :id OR player2_id = :id", id: player.id)
                          .where.not(winner_id: nil)
                          .count,
        game_difference: game_difference(player, cycle)
      }
    end

    # Group by wins
    grouped = rankings.group_by { |r| r[:wins] }

    # Apply tie-breaking within each group, then sort groups by wins descending
    grouped.keys.sort.reverse.flat_map do |wins|
      group = grouped[wins]
      if group.size == 1
        group
      elsif group.size == 2
        # 2-player tie: use direct head-to-head
        p1, p2 = group
        result = direct_head_to_head(p1[:player], p2[:player], cycle)
        result > 0 ? [p1, p2] : [p2, p1]
      else
        # 3+ player tie: use game difference
        group.sort_by { |r| -r[:game_difference] }
      end
    end
  end

  def cycle_matches(cycle)
    Match.where(cycle_id: cycle.id)
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

  def game_difference(player, cycle)
    matches = cycle_matches(cycle).where("player1_id = :id OR player2_id = :id", id: player.id)
                                   .where.not(winner_id: nil)

    points_scored = matches.sum do |m|
      m.player1_id == player.id ? (m.player1_score || 0) : (m.player2_score || 0)
    end

    points_conceded = matches.sum do |m|
      m.player1_id == player.id ? (m.player2_score || 0) : (m.player1_score || 0)
    end

    points_scored - points_conceded
  end

  def direct_head_to_head(player1, player2, cycle)
    # Returns: 1 if player1 won more, -1 if player2 won more, 0 if equal
    p1_wins = cycle_matches(cycle)
      .where(winner_id: player1.id)
      .where("(player1_id = :p2 AND player2_id = :p1) OR (player1_id = :p1 AND player2_id = :p2)",
             p1: player1.id, p2: player2.id)
      .count

    p2_wins = cycle_matches(cycle)
      .where(winner_id: player2.id)
      .where("(player1_id = :p1 AND player2_id = :p2) OR (player1_id = :p2 AND player2_id = :p1)",
             p1: player1.id, p2: player2.id)
      .count

    p1_wins <=> p2_wins
  end

  def calculate_social_rankings(players)
    # Calculate base stats
    rankings = players.map do |player|
      {
        player: player,
        wins: Match.where(winner: player, cycle_id: nil).count,
        matches_played: Match.where(cycle_id: nil)
                             .where("player1_id = ? OR player2_id = ?", player.id, player.id)
                             .where.not(winner_id: nil)
                             .count,
        game_difference: social_game_difference(player)
      }
    end

    # Group by wins
    grouped = rankings.group_by { |r| r[:wins] }

    # Apply tie-breaking within each group, then sort groups by wins descending
    grouped.keys.sort.reverse.flat_map do |wins|
      group = grouped[wins]
      if group.size == 1
        group
      elsif group.size == 2
        # 2-player tie: use direct head-to-head
        p1, p2 = group
        result = social_direct_head_to_head(p1[:player], p2[:player])
        result > 0 ? [p1, p2] : [p2, p1]
      else
        # 3+ player tie: use game difference
        group.sort_by { |r| -r[:game_difference] }
      end
    end
  end

  def social_game_difference(player)
    matches = Match.where(cycle_id: nil)
                   .where("player1_id = :id OR player2_id = :id", id: player.id)
                   .where.not(winner_id: nil)

    points_scored = matches.sum do |m|
      m.player1_id == player.id ? (m.player1_score || 0) : (m.player2_score || 0)
    end

    points_conceded = matches.sum do |m|
      m.player1_id == player.id ? (m.player2_score || 0) : (m.player1_score || 0)
    end

    points_scored - points_conceded
  end

  def social_direct_head_to_head(player1, player2)
    p1_wins = Match.where(cycle_id: nil, winner_id: player1.id)
      .where("(player1_id = :p2 AND player2_id = :p1) OR (player1_id = :p1 AND player2_id = :p2)",
             p1: player1.id, p2: player2.id)
      .count

    p2_wins = Match.where(cycle_id: nil, winner_id: player2.id)
      .where("(player1_id = :p1 AND player2_id = :p2) OR (player1_id = :p2 AND player2_id = :p1)",
             p1: player1.id, p2: player2.id)
      .count

    p1_wins <=> p2_wins
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
