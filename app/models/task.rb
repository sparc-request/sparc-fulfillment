class Task < ActiveRecord::Base

  has_paper_trail
  acts_as_paranoid

  belongs_to :identity
  belongs_to :assignee,
             class_name: "Identity"
  belongs_to :assignable, polymorphic: true

  validates :assignee_id, presence: true
  validates :due_at, presence: true

  after_create   :increment_assignee_counter, unless: :complete?
  after_update   :update_assignee_counter
  before_destroy :decrement_assignee_counter, unless: :complete?

  def due_at=(due_date)
    write_attribute(:due_at, Time.strptime(due_date, "%m-%d-%Y")) if due_date.present?
  end

  private

  def increment_assignee_counter
    assignee.update_counter(:tasks, 1)
  end

  def decrement_assignee_counter
    assignee.update_counter(:tasks, -1)
  end

  def update_assignee_counter
    if self.complete_changed?(from: false, to: true)
      decrement_assignee_counter
    elsif self.complete_changed?(from: true, to: false)
      increment_assignee_counter

  def self.my_completed_tasks user, show_complete

    if show_complete
      return where("(assignee_id = ?) AND complete = ?", user.id, show_complete)
    else
      return where("(assignee_id = ?) AND complete = ?", user.id, false)
    end
  end

  def self.my_tasks user, show_tasks
    if show_tasks
      return where("complete = ?", false)
    else
      return where("(assignee_id = ?) AND complete = ?", user.id, false)
    end
  end
end
