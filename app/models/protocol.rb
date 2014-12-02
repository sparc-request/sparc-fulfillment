class Protocol < ActiveRecord::Base
  acts_as_paranoid

  has_many :arms, :dependent => :destroy

  after_create :fetch_protocol_from_sparc

  accepts_nested_attributes_for :arms

  def fetch_protocol_from_sparc
    ProtocolUpdaterJob.enqueue(id)
  end

  def self.statuses
    ['Nexus Approved', 'Complete']
  end
end
