class Notification < ActiveRecord::Base

  validates :sparc_id,
            :kind,
            :action,
            :callback_url,
            presence: true

  validate :duplicate_not_present?, on: :create

  after_create :create_or_update_object

  def duplicate_not_present?
    if action == "create" && Notification.where({ sparc_id: sparc_id, action: action, callback_url: callback_url }).any?
      errors.add :notification, 'Duplicate detected'
    end
  end

  private

  def create_or_update_object
    NotificationDispatcher.new(self).dispatch
  end
end
