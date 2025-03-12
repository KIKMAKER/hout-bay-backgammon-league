# app/controllers/admin/cycles_controller.rb
module Admin
  class CyclesController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_group

    def new
      @cycle = @group.cycles.new
    end

    def create
      @cycle = @group.cycles.new(cycle_params)
      @cycle.end_date = @cycle.start_date + @cycle.catch_up_weeks.weeks + @cycle.weeks.weeks
      if @cycle.save
        generate_matches_for_cycle(@cycle)
        redirect_to admin_group_path(@group), notice: "Cycle created and matches generated!"
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_group
      @group = Group.find(params[:group_id])
    end

    def cycle_params
      params.require(:cycle).permit(:start_date, :end_date, :weeks, :catch_up_weeks)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Unauthorized!" unless current_user.admin?
    end

    def generate_matches_for_cycle(cycle)
      players = cycle.group.users.to_a

      players.combination(2).each do |player1, player2|
        Match.create!(
          player1: player1,
          player2: player2,
          cycle: cycle,
          match_date: cycle.start_date + rand(0..(cycle.weeks * 7)).days
        )
      end
    end
  end
end
