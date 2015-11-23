class Protocol < ActiveRecord::Base

  attr_accessor :document_counter_updated

  has_paper_trail
  acts_as_paranoid

  belongs_to :sub_service_request
  belongs_to :sparc_protocol, class_name: 'Sparc::Protocol', foreign_key: :sparc_id

  has_one :organization, through: :sub_service_request
  has_one :human_subjects_info, primary_key: :sparc_id

  has_many :project_roles,    primary_key: :sparc_id
  has_many :service_requests, primary_key: :sparc_id
  has_many :arms,             dependent: :destroy
  has_many :line_items,       dependent: :destroy
  has_many :fulfillments,     through: :line_items
  has_many :participants,     dependent: :destroy
  has_many :appointments,     through: :participants
  has_many :procedures,       through: :appointments
  has_many :documents,        as: :documentable

  before_save :set_documents_count

  after_save :update_faye
  after_destroy :update_faye

  delegate  :irb_approval_date,
            :irb_expiration_date,
            :irb_number,
            to: :human_subjects_info,
            allow_nil: true

  delegate  :status,
            :owner,
            :service_requester,
            to: :sub_service_request

  delegate :short_title,
           :title,
           :funding_source,
           to: :sparc_protocol

  def self.title id
    ["Protocol", Protocol.find(id).srid].join(' ')
  end

  def sparc_uri
    [
      ENV.fetch('GLOBAL_SCHEME'),
      '://',
      ENV.fetch('SPARC_API_HOST'),
      '/portal/admin/sub_service_requests/',
      sub_service_request_id
    ].join
  end

  def srid # this is a combination of sparc_id and sub_service_request.ssr_id
    "#{sparc_id} - #{sub_service_request.ssr_id}"
  end

  #For displaying the subsidy committed on the index page
  def subsidy_committed
    study_cost  = self.study_cost / 100.00
    subsidy     = self.stored_percent_subsidy / 100.00

    ((study_cost * subsidy) * 100).to_i
  end

  #TODO:Placeholder for subsidy expended. To be completed when participant calendars are built out.
  def subsidy_expended
    "$0.00"
  end

  def pi
    project_roles.where(role: "primary-pi").first.identity
  end

  def coordinators
    project_roles.where(role: "research-assistant-coordinator").map(&:identity)
  end

  def short_title_with_sparc_id
    "(#{self.srid}) #{self.short_title}"
  end

  def one_time_fee_line_items
    line_items.includes(:service).where(:services => {:one_time_fee => true})
  end

  private

  def update_faye
    FayeJob.perform_later(self) unless self.document_counter_updated
  end

  def set_documents_count
    update_attributes(unaccessed_documents_count: 0) if self.unaccessed_documents_count < 0
  end
end
