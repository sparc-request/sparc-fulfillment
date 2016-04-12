class IdentityOrganizations
  def initialize(id) 
    @id = id
  end

  def collect_clinical_provider_organizations_with_protocols
    collect_orgs_with_protocols = []
    orgs = Organization.joins(:clinical_providers).where(clinical_providers: { identity_id: @id}).joins(:sub_service_requests).uniq
    orgs.each do |org|
      if org.has_protocols?
        collect_orgs_with_protocols << org
      end
    end
  end

  def collect_clinical_provider_organizations
    collect_orgs = []
    orgs = Organization.joins(:clinical_providers).where(clinical_providers: { identity_id: @id})
    orgs.each do |org|
      collect_orgs << org
    end
  end

  def clinical_provider_organizations(with_protocols = false)
    cp_orgs = []
    if with_protocols == true
      cp_orgs << collect_clinical_provider_organizations_with_protocols
    else
      cp_orgs << collect_clinical_provider_organizations
    end
    cp_orgs.flatten
  end


  # returns organizations that have super_user attached AND all the children organizations.
  def super_user_organizations(with_protocols = false)
    super_user_orgs = []
    orgs = Organization.joins(:super_users).where(super_users: { identity_id: @id})
    if with_protocols == true
      orgs.each do |org|
        if org.has_protocols?
          super_user_orgs << org
        end
        super_user_orgs << org.child_orgs_with_protocols
      end 
    else
      orgs.each do |org|
        super_user_orgs << org
        super_user_orgs << org.all_child_organizations
      end
    end
    super_user_orgs.flatten.uniq
  end
  
  # returns organizations that have a clinical provider and super user access AND have protocols.
  def fulfillment_organizations_with_protocols
    (clinical_provider_organizations(true) + super_user_organizations(true)).uniq
  end

  # returns organizations that have a clinical provider and super user access
  def fulfillment_organizations
    (clinical_provider_organizations(false) + super_user_organizations(false)).uniq
  end
end