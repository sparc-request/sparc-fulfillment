class Protocol < ActiveRecord::Base
  acts_as_paranoid

  has_many :arms, :dependent => :destroy
  has_many :participants, :dependent => :destroy

  after_create :fetch_protocol
  after_save :update_via_faye

  def update_via_faye
    channel = "/protocols/list"
    message = {:channel => channel, :data => "woohoo", :ext => {:auth_token => FAYE_TOKEN}}
    uri = URI.parse("http://localhost:9292/faye")
    Net::HTTP.post_form(uri, :message => message.to_json) 
  end

  def fetch_protocol
    ProtocolWorkerJob.enqueue(self.sparc_id, self.sparc_sub_service_request_id)
  end

  def self.statuses
    ['All', 'Nexus Approved', 'Complete']
  end
end
