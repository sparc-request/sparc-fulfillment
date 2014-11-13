class Protocol < ActiveRecord::Base
  acts_as_paranoid
  
  has_many :arms, :dependent => :destroy

end
