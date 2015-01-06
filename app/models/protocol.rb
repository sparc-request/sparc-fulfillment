 class Protocol < ActiveRecord::Base
  acts_as_paranoid

  has_many :arms, dependent: :destroy
  has_many :participants, dependent: :destroy

  after_save :update_via_faye

  def update_via_faye
    channel = "/protocols/list"
    message = {:channel => channel, :data => "woohoo", :ext => {:auth_token => ENV['FAYE_TOKEN']}}
    uri = URI.parse('http://' + ENV['CWF_FAYE_HOST'] + '/faye')
    Net::HTTP.post_form(uri, :message => message.to_json)
  end

  def self.statuses
    ['All', 'Draft', 'Submitted', 'Get a Quote', 'In Process', 'Complete', 'Awaiting Requester Response', 'On Hold']
  end

  #For displaying the subsidy committed on the index page
  def subsidy_committed
    study_cost = self.study_cost / 100.00
    subsidy = self.stored_percent_subsidy / 100.00
    field = sprintf('%.2f', (study_cost * subsidy))

    field
  end

  #TODO:Placeholder for subsidy expended. To be completed when participant calendars are built out.
  def subsidy_expended
    "$0"
  end
end
