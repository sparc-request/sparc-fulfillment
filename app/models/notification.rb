class Notification < ActiveRecord::Base

  validates :sparc_id,  :action,
                        :callback_url,
                        presence: true
end
