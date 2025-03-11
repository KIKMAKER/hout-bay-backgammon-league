class Match < ApplicationRecord
  belongs_to :player1
  belongs_to :player2
  belongs_to :winner
  belongs_to :cycle
end
