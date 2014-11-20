class Participant < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :protocol
end