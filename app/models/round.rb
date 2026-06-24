class Round < ApplicationRecord
  # Virtual attributes for form (not persisted to Round, applied to cycles)
  attr_accessor :weeks, :catch_up_weeks

  has_many :cycles, inverse_of: :round, dependent: :nullify
  has_many :payments, dependent: :destroy
  accepts_nested_attributes_for :cycles

  validates :start_date, :end_date, presence: true
  validate  :end_after_start

  def players
    User.joins(group: :cycles).where(cycles: { round_id: id }).distinct
  end

  def display_name
    "#{start_date.strftime('%d %b %Y')} – #{end_date.strftime('%d %b %Y')}"
  end

  private

  def end_after_start
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "must be after start date") if end_date <= start_date
  end

  def name
    "#{start_date.strftime('%d %b %Y')} – #{end_date.strftime('%d %b %Y')}"
  end
end
