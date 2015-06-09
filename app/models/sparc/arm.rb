class Sparc::Arm < ActiveRecord::Base
  
  include SparcShard

  belongs_to :protocol

  has_many :line_items_visits
  has_many :line_items, :through => :line_items_visits
  has_many :visit_groups
  has_many :visits, :through => :line_items_visits

  def line_items_grouped_by_core
    line_items.includes(:service).where(:services => {:one_time_fee => false}).group_by{|li| li.service.organization}
  end
end
