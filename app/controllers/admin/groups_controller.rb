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
        flash.now[:alert] = "No active cycle for your group."
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
  end
end
