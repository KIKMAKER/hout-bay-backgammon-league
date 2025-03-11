class Admin::CyclesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    @cycles = Cycle.includes(:group).order(created_at: :desc)
  end

  def new
    @cycle = Cycle.new
    @groups = Group.includes(:users)
  end

  def create
    @cycle = Cycle.new(cycle_params)

    if @cycle.save
      generate_matches_for_cycle(@cycle)
      redirect_to admin_cycles_path, notice: "Cycle created and matches generated!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def cycle_params
    params.require(:cycle).permit(:start_date, :weeks, :end_date, :group_id)
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
