module Admin
  class LoansController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_book

    def create
      user = User.find(params[:user_id])
      latest_round = Round.order(start_date: :desc).first

      if latest_round && !user.paid_for_round?(latest_round)
        return redirect_to admin_books_path, alert: "#{user.username} has not paid their fees for the current cycle."
      end

      if @book.active_loan
        return redirect_to admin_books_path, alert: "#{@book.title} is already on loan."
      end

      Loan.create!(
        book: @book,
        user: user,
        loaned_at: Time.current,
        loaned_by: current_user
      )

      redirect_to admin_books_path, notice: "#{@book.title} loaned to #{user.username}."
    end

    def destroy
      loan = @book.loans.find(params[:id])
      loan.update!(returned_at: Time.current)
      redirect_to admin_books_path, notice: "#{@book.title} returned by #{loan.user.username}."
    end

    private

    def set_book
      @book = Book.find(params[:book_id])
    end

    def authorize_admin!
      redirect_to root_path, alert: "Unauthorized" unless current_user.admin?
    end
  end
end
