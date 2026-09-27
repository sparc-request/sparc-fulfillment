class TimeTracking < ApplicationRecord
  belongs_to :identity
  belongs_to :protocol
  belongs_to :sub_service_request
  belongs_to :line_item

  def stop
    now = Time.current
    diff_hours = ((now - started_at) / 3600.0).round(2)
    update(ended_at: now, quantity: diff_hours)
    self
  end

  def self.stop_active_for(identity)
    where(identity_id: identity.id, ended_at: nil).map(&:stop)
  end

end
