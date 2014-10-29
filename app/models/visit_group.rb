class VisitGroup < ActiveRecord::Base
  acts_as_paranoid
  
  belongs_to :arm

  has_many :visits, :dependent => :destroy
end
