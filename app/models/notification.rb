class Notification < ActiveRecord::Base

  validates :sparc_id,
            :kind,
            :action,
            :callback_url,
            presence: true

  after_create :create_or_update_object

  private

  def create_or_update_object
    NotificationDispatcher.new(self).dispatch
  end
end
