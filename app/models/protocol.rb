class Protocol < ActiveRecord::Base

  STATUSES = ['All', 'Draft', 'Submitted', 'Get a Quote', 'In Process', 'Complete', 'Awaiting Requester Response', 'On Hold', 'In Admin Review', 'Active', 'Administrative Review', 'In Committee Review', 'Invoiced', 'In Fulfillment Queue', 'Approved', 'Declined', 'Withdrawn'].freeze

  has_paper_trail
  acts_as_paranoid

  belongs_to :sub_service_request

  has_one :organization, through: :sub_service_request
  has_one :human_subjects_info, primary_key: :sparc_id

  has_many :service_requests
  has_many :arms,           dependent: :destroy
  has_many :line_items,     dependent: :destroy
  has_many :participants,   dependent: :destroy
  has_many :project_roles,  dependent: :destroy
  has_many :appointments,   through: :participants
  has_many :procedures,     through: :appointments

  after_save :update_faye
  after_destroy :update_faye

  delegate  :irb_approval_date,
            :irb_expiration_date,
            :irb_number,
            to: :human_subjects_info

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
    list_display = "(#{self.sparc_id}) #{self.short_title}"
    return list_display
  end

  def one_time_fee_line_items
    line_items.includes(:service).where(:services => {:one_time_fee => true})
  end

  private

  def update_faye
    FayeJob.enqueue self
  end
end
