class Protocol < ActiveRecord::Base
  acts_as_paranoid

  has_many :arms, :dependent => :destroy
  has_many :participants, :dependent => :destroy

  after_create :update_from_sparc
  after_save :update_via_faye

  def update_via_faye
    channel = "/protocols/list"
    message = {:channel => channel, :data => "woohoo", :ext => {:auth_token => FAYE_TOKEN}}
    uri = URI.parse('http://' + ENV['CWF_FAYE_HOST'] + '/faye')
    Net::HTTP.post_form(uri, :message => message.to_json)
  end

  accepts_nested_attributes_for :arms

  def update_from_sparc
    RemoteObjectUpdaterJob.enqueue(self.id, self.class.to_s)
  end

  def self.statuses
    ['All', 'Draft', 'Submitted', 'Get a Quote', 'In Process', 'Complete', 'Awaiting Requester Response', 'On Hold']
  end
end
