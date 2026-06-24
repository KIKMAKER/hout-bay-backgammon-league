module Admin
  class PaymentsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_round

    def index
      @players = @round.players.includes(:payments).order(:username)
    end

    def create
      user = User.find(params[:user_id])
      Payment.find_or_create_by!(user: user, round: @round) do |p|
        p.paid_at = Time.current
        p.marked_by = current_user
      end
      redirect_to admin_round_payments_path(@round), notice: "#{user.username} marked as paid."
    end

    def destroy
      payment = Payment.find_by!(id: params[:id], round: @round)
      user = payment.user
      payment.destroy
      redirect_to admin_round_payments_path(@round), notice: "#{user.username} marked as unpaid."
    end

    private

    def set_round
      @round = Round.find(params[:round_id])
    end

    def authorize_admin!
      redirect_to root_path, alert: "Unauthorized" unless current_user.admin?
    end
  end
end
