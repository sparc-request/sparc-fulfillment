class Identity < ActiveRecord::Base

  include SparcShard

  devise :database_authenticatable, :rememberable, :trackable, :omniauthable

  has_one :identity_counter, dependent: :destroy

  has_many :documents, as: :documentable
  has_many :project_roles
  has_many :tasks, as: :assignable
  has_many :reports
  has_many :clinical_providers
  has_many :super_users

  delegate :tasks_count, :unaccessed_documents_count, to: :identity_counter


  def protocols
    fulfillment_organizations_with_protocols.any? ? fulfillment_organizations_with_protocols.map(&:protocols).flatten : []
  end

  def readonly?
    false
  end

  def identity_counter
    IdentityCounter.find_or_create_by(identity: self)
  end

  # counter should be a symbol like :tasks for tasks_counter
  def update_counter(counter, amount)
    IdentityCounter.update_counter(self.id, counter, amount)
  end

  def full_name
    [first_name, last_name].join(' ')
  end
  # returns organizations that have a clinical provider on them AND have protocols.  It does not return child organizations.
  def clinical_provider_organizations_with_protocols
    orgs_with_protocols = []
    orgs = Organization.joins(:clinical_providers).where(clinical_providers: { identity_id: id}).joins(:sub_service_requests).uniq
    orgs.each do |org|
      if org.has_protocols?
        orgs_with_protocols << org
      end
    end
    orgs_with_protocols
  end

  # returns organizations that have super_user attached AND all the children organizations.
  def super_user_organizations_with_protocols
    super_user_orgs_with_protocols = []
    orgs = Organization.joins(:super_users).where(super_users: { identity_id: id})
    orgs.each do |org|
      if org.has_protocols?
        super_user_orgs_with_protocols << org
      end
      super_user_orgs_with_protocols << org.child_orgs_with_protocols
    end
    super_user_orgs_with_protocols.flatten.uniq
  end

  def fulfillment_organizations_with_protocols
    (clinical_provider_organizations_with_protocols + super_user_organizations_with_protocols).uniq
  end
end
