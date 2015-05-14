class Task < ActiveRecord::Base

  has_paper_trail
  acts_as_paranoid

  belongs_to :identity
  belongs_to :assignee,
             class_name: "Identity"
  belongs_to :assignable, polymorphic: true

  validates :assignee_id, presence: true
  validates :due_at, presence: true

  after_create :increment_identity_counter
  after_update :update_identity_counter
  after_destroy :decrement_identity_counter

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

  def increment_identity_counter
    identity.update_counter(:tasks, 1)
  end

  def decrement_identity_counter
    identity.update_counter(:tasks, -1)
  end

  def update_identity_counter
    if self.complete_changed?(from: false, to: true)
      decrement_identity_counter
    elsif self.complete_changed?(from: true, to: false)
      increment_identity_counter
    end
  end

end
