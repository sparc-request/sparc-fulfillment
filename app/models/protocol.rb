class Protocol < ActiveRecord::Base

  STATUSES = ['All', 'Draft', 'Submitted', 'Get a Quote', 'In Process', 'Complete', 'Awaiting Requester Response', 'On Hold'].freeze

  acts_as_paranoid

  has_many :arms, dependent: :destroy
  has_many :participants, dependent: :destroy
  has_many :user_roles

  after_save :update_faye
  after_destroy :update_faye

  #For displaying the subsidy committed on the index page
  def subsidy_committed
    study_cost  = self.study_cost / 100.00
    subsidy     = self.stored_percent_subsidy / 100.00

    sprintf('%.2f', (study_cost * subsidy))
  end

  #TODO:Placeholder for subsidy expended. To be completed when participant calendars are built out.
  def subsidy_expended
    "$0"
  end

  def pi
    self.user_roles.where(role: "primary-pi").first.user
  end

  def coordinators
    user_roles.where(role: "research-assistant-coordinator").map(&:user)
  end

  private

  def update_faye
    FayeJob.enqueue self
  end
end
