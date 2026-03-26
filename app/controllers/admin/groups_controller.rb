# app/controllers/admin/groups_controller.rb
module Admin
  class GroupsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    def index
      @groups = Group.all
    end

    def show
      @group = Group.find(params[:id])
      @cycle   = @group.cycles.order(start_date: :desc).first   # picks today's cycle (or latest)

      if @cycle
        @players   = @group.users
        @rankings  = calculate_rankings(@players, @cycle)
      else
        @players   = @group.users
        @rankings  = []
        flash.now[:notice] = "No cycle created yet for this group. Create a cycle to start tracking matches."
      end
    end

    def new
      @group = Group.new
    end

    def create
      @group = Group.new(group_params)
      if @group.save
        redirect_to admin_group_path(@group)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def add_members
      @group = Group.find(params[:id])
      # Only users with no group
      @unassigned_users = User.where(group_id: nil).order(:username)
      @group.user_ids = []
    end

    def assign_members
      @group = Group.find(params[:id])
      user_ids = Array(params[:group][:user_ids]).reject(&:blank?)

      User.where(id: user_ids).update_all(group_id: @group.id)

      redirect_to admin_group_path(@group),
                  notice: "#{user_ids.size} users assigned to #{@group.title}"
    end

    private

    def group_params
      params.require(:group).permit(:title)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Unauthorized!" unless current_user.admin?
    end

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
  end
end
