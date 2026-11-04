class TimeTracking < ApplicationRecord
  belongs_to :identity
  belongs_to :protocol
  belongs_to :sub_service_request
  belongs_to :line_item

  validate :component_presence_if_required_by_service

  scope :accessible_by, ->(identity) {
    managed_ssr_ids = SubServiceRequest
      .where(organization_id: identity.time_tracking_manager_organization_ids)
      .pluck(:id)

    where(identity_id: identity.id).or(where(sub_service_request_id: managed_ssr_ids))
  }

  def stop
    now = Time.current
    diff_hours = ((now - started_at) / 3600.0).round(2)
    update(ended_at: now, quantity: diff_hours)
    self
  end

  def self.stop_active_for(identity)
    where(identity_id: identity.id, ended_at: nil).map(&:stop)
  end

  private

  def component_presence_if_required_by_service
    return unless line_item&.service&.components.present?
    if component_name.blank?
      errors.add(:fulfillment_component, "field required for this service")
    end
  end

end
