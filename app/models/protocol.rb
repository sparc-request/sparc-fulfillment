class Protocol < ActiveRecord::Base
  acts_as_paranoid

  has_many :arms, :dependent => :destroy

  after_create :update_from_sparc

  accepts_nested_attributes_for :arms

  def update_from_sparc
    RemoteObjectUpdaterJob.enqueue(self.id, self.class.to_s)
  end

  def self.statuses
    ['Nexus Approved', 'Complete']
  end
end
