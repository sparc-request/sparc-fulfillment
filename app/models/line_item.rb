class LineItem < ActiveRecord::Base
  acts_as_paranoid
  
  belongs_to :arm
  belongs_to :service

  has_many :visits, :dependent => :destroy

  attr_accessible :sparc_id
  attr_accessible :arm_id
  attr_accessible :service_id
  attr_accessible :name
  attr_accessible :cost
  attr_accessible :sparc_core_id
  attr_accessible :sparc_core_name
  attr_accessible :sparc_program_id
  attr_accessible :sparc_program_name
end
