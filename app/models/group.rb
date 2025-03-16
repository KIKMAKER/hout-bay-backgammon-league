class Group < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :cycles, dependent: :destroy
  attr_accessor :user_ids
  # VALID_TITLES = ["Group A", "Group B", "Group C"]

  validates :title, presence: true, uniqueness: true
  # inclusion: { in: VALID_TITLES, message: "%{value} is not a valid group title" }
end
