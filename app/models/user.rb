class User < ActiveRecord::Base

  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  has_many :user_roles
  has_many :tasks, as: :assignable
  has_many :notes, as: :notable

  def full_name
    [first_name, last_name].join(' ')
  end
end
