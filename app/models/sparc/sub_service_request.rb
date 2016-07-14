class Sparc::SubServiceRequest < ActiveRecord::Base
  
  include SparcShard
  
  belongs_to :service_requester, class_name: "Identity", foreign_key: "service_requester_id"
  belongs_to :owner, :class_name => 'Identity', :foreign_key => "owner_id"
  belongs_to :service_request
  belongs_to :organization

  has_many :line_items
  has_many :one_time_fee_line_items, -> { one_time_fee }, :class_name => 'LineItem'
  has_many :per_participant_line_items, -> { per_participant }, :class_name => 'LineItem'
  has_many :reports

  has_one :protocol, :through => :service_request


end
