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
    if clinical_providers.any?
      clinical_providers.
        map { |clinical_provider| clinical_provider.organization.protocols }.
        compact.
        flatten
    else
      Array.new
    end
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

  def clinical_provider_organizations
    orgs = []

    self.clinical_providers.map(&:organization).each do |org|
      orgs << org
      orgs << org.all_child_organizations
    end

    orgs.flatten.uniq
  end

  def super_user_organizations
    orgs = []

    self.super_users.map(&:organization).each do |org|
      orgs << org
      orgs << org.all_child_organizations
    end

    orgs.flatten.uniq
  end

  def fulfillment_access_organizations
    clinical_provider_organizations + super_user_organizations.uniq
  end
end
