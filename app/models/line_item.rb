class LineItem < ActiveRecord::Base

  has_paper_trail
  acts_as_paranoid

  belongs_to :protocol
  belongs_to :arm
  belongs_to :service

  has_many :visit_groups, through: :arm
  has_many :visits, -> { includes(:visit_group).order("visit_groups.position") }, dependent: :destroy
  has_many :notes, as: :notable
  has_many :documents, as: :documentable
  has_many :fulfillments
  has_many :components, as: :composable

  delegate  :name,
            :cost,
            :sparc_core_id,
            :sparc_core_name,
            to: :service

  after_create :increment_sparc_service_counter
  after_destroy :decrement_sparc_service_counter

  def increment_sparc_service_counter
    RemoteServiceUpdaterJob.perform_later(self.service, 1)
  end

  def decrement_sparc_service_counter
    RemoteServiceUpdaterJob.perform_later(self.service, -1)
  end 

end
