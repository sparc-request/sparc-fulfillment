class VisitGroup < ActiveRecord::Base
  belongs_to :arm

  has_many :visits, :dependent => :destroy
end
