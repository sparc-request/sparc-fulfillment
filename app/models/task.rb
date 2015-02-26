class Task < ActiveRecord::Base

  acts_as_paranoid
  belongs_to :procedure
end