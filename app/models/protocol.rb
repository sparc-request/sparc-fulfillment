class Protocol < ActiveRecord::Base
  acts_as_paranoid
  
  has_many :arms, :dependent => :destroy

  after_create :fetch_protocol

  def fetch_protocol
    ProtocolWorkerJob.enqueue(self.sparc_id, self.sparc_sub_service_request_id, true)
  end

end
