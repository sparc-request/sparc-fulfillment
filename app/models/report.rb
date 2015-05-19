class Report < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  has_one :document, as: :documentable
end
