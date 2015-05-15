class Protocol < ActiveRecord::Base

  STATUSES = ['All', 'Draft', 'Submitted', 'Get a Quote', 'In Process', 'Complete', 'Awaiting Requester Response', 'On Hold'].freeze

  has_paper_trail
  acts_as_paranoid

  has_many :arms, dependent: :destroy
  has_many :line_items, dependent: :destroy
  has_many :participants, dependent: :destroy
  has_many :user_roles

  after_save :update_faye
  after_destroy :update_faye

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
    user_roles.where(role: "primary-pi").first.user
  end

  def coordinators
    user_roles.where(role: "research-assistant-coordinator").map(&:user)
  end

  def one_time_fee_line_items
    line_items.includes(:service).where(:services => {:one_time_fee => true})
  end

  private

  def update_faye
    FayeJob.enqueue self
  end
end
