module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_user, except: :index

    def matches
      @matches = Match.where(
        "player1_id = :id OR player2_id = :id",
        id: @player.id
      ).order(match_date: :desc)
    end

    def index
      @users = User.includes(:group).order(:username)
    end

    def edit; end

    def update
      if @user.update(user_params)
        redirect_to admin_users_path, notice: "Member updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:username, :email, :group_id, :admin)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Unauthorized" unless current_user.admin?
    end
  end
end
