class Identity < ActiveRecord::Base

  include SparcShard

  devise :database_authenticatable, :rememberable, :trackable

  has_one :identity_counter, dependent: :destroy
  has_many :project_roles
  has_many :tasks, as: :assignable
  has_many :reports
  has_many :clinical_providers

  delegate :tasks_count, to: :identity_counter

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

  def update_counter(counter, amount)
    IdentityCounter.update_counter(self.id, counter, amount)
  end

  def full_name
    [first_name, last_name].join(' ')
  end
end
