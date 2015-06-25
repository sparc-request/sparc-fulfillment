class SubServiceRequest < ActiveRecord::Base

  STATUSES = [
    'all',
    'draft',
    'submitted',
    'get_a_quote',
    'in_process',
    'complete',
    'awaiting_pi_approval',
    'on_hold',
    'ctrc_review',
    'ctrc_approved',
    'administrative_review',
    'committee_review',
    'invoiced',
    'fulfillment_queue',
    'approved',
    'declined',
    'withdrawn'
  ].freeze

  include SparcShard

  has_one :protocol

  belongs_to :owner, class_name: 'Identity'
  belongs_to :organization
  belongs_to :service_request

  delegate :requester, to: :service_request
end
