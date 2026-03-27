class Match < ApplicationRecord
  belongs_to :player1, class_name: "User"
  belongs_to :player2, class_name: "User"
  belongs_to :winner, class_name: "User", optional: true
  belongs_to :cycle, optional: true
  delegate   :group, to: :cycle, allow_nil: true

  validates :match_date, presence: true
  validate :scores_within_range_for_competitive_match

  after_update :set_winner, if: -> { player1_score.present? && player2_score.present? }

  scope :completed, -> { where.not(winner_id: nil) } # or: where.not(player1_score: nil, player2_score: nil)
  scope :recent,    -> { order(Arel.sql("match_date DESC NULLS LAST, created_at DESC")) }


  def social?
    cycle.nil?
  end

  private

  def scores_within_range_for_competitive_match
    return if cycle_id.nil?

    { player1_score: player1_score, player2_score: player2_score }.each do |attr, score|
      next if score.nil?
      errors.add(attr, "must be between 0 and 11") unless score.between?(0, 11)
    end
  end

  def set_winner
    if player1_score > player2_score
      update_column(:winner_id, player1_id)
    elsif player2_score > player1_score
      update_column(:winner_id, player2_id)
    else
      update_column(:winner_id, nil) # Handle ties if necessary
    end
  end
end
