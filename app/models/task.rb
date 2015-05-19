class Task < ActiveRecord::Base

  has_paper_trail if: Rails.env.production?
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

  def self.mine identity, show_complete

    if show_complete
      return where("(assignee_id = ? OR identity_id = ?) AND complete = ?", identity.id, identity.id, show_complete)
    else
      return where("(assignee_id = ? OR identity_id = ?) AND complete = ?", identity.id, identity.id, false)
    end
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
    end
  end
end
