class Task < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :user
  belongs_to :assignee,
             class_name: "User",
             counter_cache: true
  belongs_to :assignable, polymorphic: true

  validates :assignee_id, presence: true

  scope :mine, -> (user) { where("assignee_id = ? OR user_id = ?", user.id, user.id) }

  after_update :update_counter

  def update_counter
    if self.complete_changed?(from: false, to: true)
      User.decrement_counter(:tasks_count, self.assignee.id)
    elsif self.complete_changed?(from: true, to: false)
      User.increment_counter(:tasks_count, self.assignee.id)
    end
  end
end
