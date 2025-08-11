class Round < ApplicationRecord
  has_many :cycles, dependent: :nullify
  validates :start_date, :end_date, presence: true
  validate  :end_after_start

  private

  def end_after_start
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "must be after start date") if end_date <= start_date
  end
  
  def name
    "#{start_date.strftime('%d %b %Y')} – #{end_date.strftime('%d %b %Y')}"
  end
end
