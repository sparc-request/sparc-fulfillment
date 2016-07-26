class IdentityOrganizations
  def initialize(id)
    @id = id
  end

  def fulfillment_access_protocols
    fetch_rights
    Protocol.joins(:sub_service_request).where(sub_service_requests: {organization_id: @super_user_orgs + authorized_child_organizations(@super_user_orgs) + @clinical_provider_orgs}).distinct
  end

  def fulfillment_organizations_with_protocols
    fetch_rights
    Organization.joins(:protocols).where(id: @super_user_orgs + authorized_child_organizations(@super_user_orgs) + @clinical_provider_orgs).distinct
  end

  private

  def fetch_rights
    @super_user_orgs ||= Organization.includes(:super_users).where(super_users: {identity_id: @id}).references(:super_users).uniq(:organizations)
    @clinical_provider_orgs ||= Organization.includes(:clinical_providers).where(clinical_providers: {identity_id: @id}).references(:clinical_providers).uniq(:organizations)
  end
  
  def authorized_child_organizations(org_ids)
    org_ids = org_ids.flatten.compact
    if org_ids.empty?
      []
    else
      orgs = Organization.where(parent_id: org_ids)
      orgs | authorized_child_organizations(orgs.pluck(:id))
    end
  end

end
