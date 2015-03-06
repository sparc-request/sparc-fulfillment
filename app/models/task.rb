class Task < ActiveRecord::Base

  TASK_TYPES = ["Study-level Task", "Participant-level Task"]

  acts_as_paranoid

end