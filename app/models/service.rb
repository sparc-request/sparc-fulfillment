class Service < ActiveRecord::Base
  acts_as_paranoid

  has_many :line_items, :dependent => :destroy

  after_create :update_from_sparc

  def update_from_sparc
    RemoteObjectUpdaterJob.enqueue(self.id, self.class.to_s)
  end
end
