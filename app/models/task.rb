class Task < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :user
  belongs_to :assignee,
             class_name: "User",
             counter_cache: true
  belongs_to :assignable, polymorphic: true

  validates :assignee_id, presence: true
end
