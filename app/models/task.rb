class Task < ActiveRecord::Base

  TASK_TYPES = ["Study-level Task", "Participant-level Task"].freeze

  acts_as_paranoid

  belongs_to :user
  belongs_to :assignee, class_name: "User"
  validates :due_date, presence: true
end