class Round < ApplicationRecord
  has_many :cycles, dependent: :nullify
  validates :start_date, :end_date, presence: true
  def name
    "#{start_date.strftime('%d %b %Y')} – #{end_date.strftime('%d %b %Y')}"
  end
end
