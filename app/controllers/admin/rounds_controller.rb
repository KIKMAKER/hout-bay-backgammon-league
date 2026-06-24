module Admin
  class RoundsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    def index
      @rounds = Round.order(start_date: :desc)
    end

    private

    def authorize_admin!
      redirect_to root_path, alert: "Unauthorized" unless current_user.admin?
    end
  end
end
