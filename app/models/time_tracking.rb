class TimeTracking < ApplicationRecord
  STATUSES = [
    IN_PROGRESS = "In Progress",
    UNDER_REVIEW = "Under Review",
    READY = "Ready for Import",
    IMPORTED = "Imported"
  ].freeze

  belongs_to :identity
  belongs_to :protocol
  belongs_to :sub_service_request
  belongs_to :line_item

  has_one :fulfillment

  validate :component_presence_if_required_by_service

  before_validation :set_default_status, on: :create

  scope :managed_by, ->(identity) {
    org_ids = identity.time_tracking_manager_organization_ids
    return none if org_ids.empty?

    managed_ssr_ids = SubServiceRequest
      .where(organization_id: org_ids)
      .pluck(:id)

    where(sub_service_request_id: managed_ssr_ids)
  }

  def import_to_fulfillment!(creator)
    service = line_item.service
    funding_source = protocol.sparc_funding_source

    fulfillment = self.fulfillment || build_fulfillment
    fulfillment.assign_attributes(
      line_item: line_item,
      creator_id: creator.id,
      performer_id: identity_id,
      fulfilled_at: date.strftime('%m/%d/%Y'),
      quantity: quantity,
      service: service,
      service_name: service.name,
      funding_source: funding_source,
      percent_subsidy: protocol.percent_subsidy,
      service_cost: line_item.cost(funding_source, date.to_time)
    )
    fulfillment.skip_components_validation = true
    fulfillment.klok_upload = true
    fulfillment.save!

    if component_name.present? && fulfillment.components.where(component: component_name).none?
      fulfillment.components.create!(component: component_name)
    end

    if notes.present? && fulfillment.notes.where(comment: notes, identity_id: identity_id).none?
      fulfillment.notes.create!(kind: 'note', comment: notes, identity_id: identity_id)
    end

    update!(status: IMPORTED)
    fulfillment
  end

  def current_status
    status.presence || IN_PROGRESS
  end

  def locked?
    current_status != IN_PROGRESS
  end

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

  def set_default_status
    self.status ||= IN_PROGRESS
  end

  def component_presence_if_required_by_service
    return unless line_item&.service&.components.present?
    if component_name.blank?
      errors.add(:fulfillment_component, "field required for this service")
    end
  end

end
