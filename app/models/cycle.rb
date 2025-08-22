class Cycle < ApplicationRecord
  belongs_to :group
  belongs_to :round
  has_many :matches, dependent: :destroy
  before_validation :copy_dates_from_round, if: -> { round && (start_date.blank? || end_date.blank?) }
  validates :start_date, :weeks, :end_date, presence: true
  validate :end_date_after_start_date


  private
  def copy_dates_from_round
    self.start_date ||= round.start_date
    self.end_date   ||= round.end_date
  end


  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date <= start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end
