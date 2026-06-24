class Loan < ApplicationRecord
  belongs_to :book
  belongs_to :user
  belongs_to :loaned_by, class_name: "User", optional: true

  scope :active, -> { where(returned_at: nil) }
  scope :overdue, -> { active.where("loaned_at < ?", 2.weeks.ago) }

  def overdue?
    returned_at.nil? && loaned_at < 2.weeks.ago
  end

  def due_date
    loaned_at + 2.weeks
  end
end
