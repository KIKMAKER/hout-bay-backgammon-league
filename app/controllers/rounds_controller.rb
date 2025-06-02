class RoundsController < ApplicationController
  before_action :authenticate_user!

  def index
    @rounds = Cycle
                .select(:id, :start_date, :end_date)
                .distinct
                .order(start_date: :desc)
  end

  # GET /rounds/:id  (id is a URL-safe slug)
  def show
    start_date, end_date = RoundSlug.decode(params[:id])
    @cycles = Cycle
                .includes(:group)
                .where(start_date: start_date, end_date: end_date)
                .order("groups.title")
  end
end
