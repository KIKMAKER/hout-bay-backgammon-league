class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :round
  belongs_to :marked_by, class_name: "User", optional: true
end
