class Match < ApplicationRecord
  belongs_to :player1, class_name: "User"
  belongs_to :player2, class_name: "User"
  belongs_to :winner, class_name: "User", optional: true
  belongs_to :cycle, optional: true
  delegate   :group, to: :cycle, allow_nil: true

  validates :match_date, presence: true

  after_update :set_winner, if: -> { player1_score.present? && player2_score.present? }

  def social?
    cycle.nil?
  end

  private

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
