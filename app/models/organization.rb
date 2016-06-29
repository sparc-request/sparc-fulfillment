class Organization < ActiveRecord::Base

  include SparcShard

  belongs_to :parent, class_name: "Organization"

  has_many :services,
            -> {where(is_available: true)}
  has_many :sub_service_requests
  has_many :protocols, through: :sub_service_requests
  has_many :pricing_setups
  has_many :non_process_ssrs_children,
            -> { where(process_ssrs: false) },
            class_name: "Organization",
            foreign_key: :parent_id
  has_many :super_users
  has_many :clinical_providers

  has_many :children, class_name: "Organization", foreign_key: :parent_id

  # Returns this organization's pricing setup that is effective on a given date.
  def effective_pricing_setup_for_date(date=Date.today)
    if self.pricing_setups.blank?
      raise ArgumentError, "Organization has no pricing setups" if self.parent.nil?
      return self.parent.effective_pricing_setup_for_date(date)
    end

    current_setups = self.pricing_setups.select { |x| x.effective_date.to_date <= date.to_date }

    raise ArgumentError, "Organization has no current effective pricing setups" if current_setups.empty?
    sorted_setups = current_setups.sort { |lhs, rhs| lhs.effective_date <=> rhs.effective_date }
    pricing_setup = sorted_setups.last

    return pricing_setup
  end

  def inclusive_child_services(scope)
    services.
      send(scope).
      push(all_child_services(scope)).
      flatten.
      sort_by(&:name)
  end

  def all_child_organizations
    [
      children,
      children.map(&:all_child_organizations)
    ].flatten
  end

  def child_orgs_with_protocols
    organizations = all_child_organizations
    organizations_with_protocols = []
    organizations.flatten.uniq.each do |organization|
      if organization.protocols.any?
        organizations_with_protocols << organization
      end
    end
    organizations_with_protocols.flatten.uniq
  end

  # NOT SURE WHAT THIS IS TRYING TO ACCOMPLISH
  def all_child_organizations_with_non_process_ssrs
    [
      non_process_ssrs_children,
      non_process_ssrs_children.map(&:all_child_organizations_with_non_process_ssrs)
    ].flatten
  end

  def all_child_services(scope)
    all_child_organizations_with_non_process_ssrs.map { |child| child.services.send(scope) }
  end
end
