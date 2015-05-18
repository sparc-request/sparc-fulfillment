class Identity < ActiveRecord::Base

  include SparcShard

  devise :database_authenticatable, :rememberable, :trackable

  has_one :identity_counter, dependent: :destroy
  has_many :identity_roles
  has_many :tasks, as: :assignable

  delegate :tasks_count, to: :identity_counter

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
