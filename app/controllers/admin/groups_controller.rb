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
      @members = @group.users
    end

    private

    def authorize_admin!
      redirect_to root_path, alert: "Unauthorized!" unless current_user.admin?
    end
  end
end
