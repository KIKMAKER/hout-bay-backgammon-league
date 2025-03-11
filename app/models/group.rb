class Group < ApplicationRecord
  VALID_TITLES = ["Group A", "Group B", "Group C"]

  validates :title, presence: true, inclusion: { in: VALID_TITLES, message: "%{value} is not a valid group title" }
end
