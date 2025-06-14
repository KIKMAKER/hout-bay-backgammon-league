class RoundsController < ApplicationController
  def index
    @rounds = Round.order(start_date: :desc)
  end

  def show
    @round  = Round.find(params[:id])
    @cycles = @round.cycles.includes(:group).order("groups.title")
  end
end
