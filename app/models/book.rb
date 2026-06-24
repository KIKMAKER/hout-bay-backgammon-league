class Book < ApplicationRecord
  has_many :loans, dependent: :destroy
  has_one :active_loan, -> { where(returned_at: nil) }, class_name: "Loan"

  def available?
    active_loan.nil?
  end
end
