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
    IdentityOrganizations.new(id).fulfillment_access_protocols
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
end