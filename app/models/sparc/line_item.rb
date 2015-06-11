class Sparc::LineItem < ActiveRecord::Base
  
  include SparcShard
  
  belongs_to :service
  belongs_to :service_request
  belongs_to :sub_service_request

  has_many :line_items_visits
  has_many :arms, through: :line_items_visits

  delegate  :name, to: :service

  scope :per_participant,  -> { includes(:service).where(:services => {one_time_fee: false}) }
  scope :one_time_fee,     -> { includes(:service).where(:services => {one_time_fee: true}) }
end
