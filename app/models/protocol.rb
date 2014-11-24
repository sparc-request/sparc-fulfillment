class Protocol < ActiveRecord::Base
  acts_as_paranoid

  has_many :arms, :dependent => :destroy
  has_many :participants, :dependent => :destroy

  after_create :fetch_protocol

  def fetch_protocol
    ProtocolWorkerJob.enqueue(self.sparc_id, self.sparc_sub_service_request_id)
  end

  def self.statuses
    ['All', 'Nexus Approved', 'Complete']
  end
end
