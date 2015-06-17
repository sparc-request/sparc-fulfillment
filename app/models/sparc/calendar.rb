class Sparc::Calendar < ActiveRecord::Base
  include SparcShard

  belongs_to :subject
  has_many :appointments
end
