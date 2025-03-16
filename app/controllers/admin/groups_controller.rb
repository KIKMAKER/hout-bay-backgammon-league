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
      @players = @group.users
      @rankings = calculate_rankings(@players)
      @latest_cycle = @group.cycles.order(start_date: :asc).last
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

    private

    def group_params
      params.require(:group).permit(:title)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Unauthorized!" unless current_user.admin?
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
end
