class Arm < ActiveRecord::Base
  acts_as_paranoid
  
  belongs_to :protocol

  has_many :line_items, :dependent => :destroy
  has_many :visit_groups, :dependent => :destroy

  attr_accessible :sparc_id
  attr_accessible :protocol_id
  attr_accessible :name
  attr_accessible :visit_count
  attr_accessible :subject_count

end
