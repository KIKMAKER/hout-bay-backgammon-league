module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_player

    def matches
      @matches = Match.where(
        "player1_id = :id OR player2_id = :id",
        id: @player.id
      ).order(match_date: :desc)
    end

    private

    def set_player
      @player = User.find(params[:id])
    end

    def authorize_admin!
      redirect_to root_path, alert: "Unauthorized" unless current_user.admin?
    end
  end
end
