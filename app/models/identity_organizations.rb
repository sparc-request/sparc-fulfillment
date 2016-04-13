class IdentityOrganizations
  def initialize(id) 
    @id = id
  end

  # returns organizations that have super_user attached AND all the children organizations.
  def super_user_organizations_with_protocols
    super_user_orgs = []
    orgs = Organization.joins(:super_users).where(super_users: { identity_id: @id})
    orgs.each do |org|
      if org.has_protocols?
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
  
  # returns organizations that have a clinical provider and super user access AND have protocols.
  def fulfillment_access_protocols
    (super_user_protocols + clinical_provider_protocols).flatten.uniq
  end
end