class Sparc::Arm < ActiveRecord::Base
  
  include SparcShard

  belongs_to :protocol

  has_many :line_items_visits
  has_many :line_items, :through => :line_items_visits
  has_many :visit_groups
  has_many :visits, :through => :line_items_visits
end
