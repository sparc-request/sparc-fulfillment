class Task < ActiveRecord::Base

  has_paper_trail
  acts_as_paranoid

  belongs_to :user
  belongs_to :assignee,
             class_name: "User",
             counter_cache: true
  belongs_to :assignable, polymorphic: true

  validates :assignee_id, presence: true

  after_update :update_counter

  def due_at=(due_date)
    write_attribute(:due_at, Time.strptime(due_date, "%m-%d-%Y")) if due_date.present?
  end

  def update_counter
    if self.complete_changed?(from: false, to: true)
      User.decrement_counter(:tasks_count, self.assignee.id)
    elsif self.complete_changed?(from: true, to: false)
      User.increment_counter(:tasks_count, self.assignee.id)
    end
  end

  def self.mine user, show_complete

    if show_complete
      return where("(assignee_id = ? OR user_id = ?) AND complete = ?", user.id, user.id, show_complete)
    else
      return where("(assignee_id = ? OR user_id = ?) AND complete = ?", user.id, user.id, false)
    end
  end
end
