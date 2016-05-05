class IdentityOrganizations
  def initialize(id) 
    @id = id
  end

  def collect_clinical_provider_organizations_with_protocols
    collect_orgs_with_protocols = []
    orgs = Organization.joins(:clinical_providers).where(clinical_providers: { identity_id: @id}).joins(:sub_service_requests).uniq
    orgs.each do |org|
      if org.protocols.any?
        collect_orgs_with_protocols << org
      end
    end
    collect_orgs_with_protocols
  end

  # returns organizations that have clinical provider attached.
  def clinical_provider_organizations_with_protocols
    cp_orgs = []
    cp_orgs << collect_clinical_provider_organizations_with_protocols
    cp_orgs.flatten 
  end

  # returns organizations that have super_user attached AND all the children organizations.
  def super_user_organizations_with_protocols
    super_user_orgs = []
    orgs = Organization.joins(:super_users).where(super_users: { identity_id: @id})
    orgs.each do |org|
      if org.protocols.any?
        super_user_orgs << org
      end
      super_user_orgs << org.child_orgs_with_protocols
    end 
    super_user_orgs.flatten.uniq
  end

  def super_user_protocols
    super_user_organizations_with_protocols.map(&:protocols).flatten
  end

  def clinical_provider_protocols
    Protocol.joins(:clinical_providers).where(clinical_providers: { identity_id: @id }).to_a
  end
  
  # returns protocols that clinical provider and super user have access to.
  def fulfillment_access_protocols
    (super_user_protocols + clinical_provider_protocols).flatten.uniq
  end
  
  # returns organizations that have a clinical provider and super user access AND have protocols.
  def fulfillment_organizations_with_protocols
    (clinical_provider_organizations_with_protocols + super_user_organizations_with_protocols).uniq
  end
end