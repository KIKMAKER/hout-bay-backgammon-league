class Group < ApplicationRecord
  has_many :users_groups
  has_many :users, through: :users_groups

  VALID_TITLES = ["Group A", "Group B", "Group C"]

  validates :title, presence: true, inclusion: { in: VALID_TITLES, message: "%{value} is not a valid group title" }
end
