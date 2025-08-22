module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_user, except: :index

    def matches
      @player = @user
      @matches = Match.where(
        "player1_id = :id OR player2_id = :id",
        id: @player.id
      ).order(match_date: :desc)
    end

    def index
      @users = User.includes(:group).order(:username)
    end

    def edit
      @matches = @user.matches.recent.limit(5)
    end

    def update
      if @user.update(user_params)
        redirect_to admin_users_path, notice: "Member updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user == current_user
        redirect_to edit_admin_user_path(@user), alert: "You can’t delete yourself." and return
      end

      if @user.admin?
        redirect_to edit_admin_user_path(@user), alert: "You can’t delete an admin user." and return
      end

      if user_has_any_matches?(@user)
        redirect_to edit_admin_user_path(@user),
          alert: "Cannot delete: this user has matches recorded. Consider deactivating instead." and return
      end

      @user.destroy!
      redirect_to admin_users_path, notice: "User deleted."
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

    def user_has_any_matches?(user)
      # Use associations if you have them; this version works regardless.
      Match.where("player1_id = :id OR player2_id = :id", id: user.id).exists?
    end
  end
end
