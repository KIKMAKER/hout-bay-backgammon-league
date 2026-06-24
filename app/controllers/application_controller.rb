class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_unpaid_round, :current_overdue_loan

  def current_unpaid_round
    return unless user_signed_in? && current_user.group_id
    @current_unpaid_round ||= Round
      .joins(cycles: :group)
      .where(cycles: { group_id: current_user.group_id })
      .where.not(id: current_user.payments.select(:round_id))
      .order(start_date: :desc)
      .first
  end

  def current_overdue_loan
    return unless user_signed_in?
    @current_overdue_loan ||= Loan.overdue.find_by(user: current_user)
  end

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :username, :group_id])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:email, :username, :group_id])
  end
end
