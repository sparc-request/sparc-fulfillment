class Task < ActiveRecord::Base

  TASK_TYPES = ["Study-level Task", "Participant-level Task"].freeze

  acts_as_paranoid

  validates :assignment, :due_date, presence: true
end