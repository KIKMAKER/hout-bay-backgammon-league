module Admin
  class BooksController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    def index
      @books = Book.includes(active_loan: :user).order(:title)
      @latest_round = Round.order(start_date: :desc).first
      @paid_users = @latest_round ? @latest_round.players.order(:username) : User.none
    end

    private

    def authorize_admin!
      redirect_to root_path, alert: "Unauthorized" unless current_user.admin?
    end
  end
end
