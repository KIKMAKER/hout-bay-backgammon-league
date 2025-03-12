class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @latest_cycle = Cycle.order(end_date: :desc).first
  end
end
