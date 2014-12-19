class LineItem < ActiveRecord::Base
  acts_as_paranoid

  default_scope { order(:sparc_core_name) }

  belongs_to :arm
  belongs_to :service

  has_many :visit_groups, through: :arm
  has_many :visits, -> { includes(:visit_group).order("visit_groups.position") }, :dependent => :destroy

  after_create :create_visits

  accepts_nested_attributes_for :visits

  private
  def create_visits
    new_visits = []
    self.visit_groups.pluck(:id).each do |vg|
      new_visits << Visit.new(visit_group_id: vg, line_item_id: self.id, research_billing_qty: 0, insurance_billing_qty: 0, effort_billing_qty: 0)
    end
     Visit.import new_visits
  end
end
