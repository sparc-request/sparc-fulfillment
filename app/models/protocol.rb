class Protocol < ActiveRecord::Base
  acts_as_paranoid
  
  has_many :arms, :dependent => :destroy

  attr_accessible :sparc_id
  attr_accessible :title
  attr_accessible :short_title
  attr_accessible :sponsor_id
end
