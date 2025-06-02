class Round < ApplicationRecord
  has_many :cycles, dependent: :nullify
end
