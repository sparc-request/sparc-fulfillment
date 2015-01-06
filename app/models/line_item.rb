class LineItem < ActiveRecord::Base
  acts_as_paranoid

  default_scope { order(:sparc_core_name) }

  belongs_to :arm
  belongs_to :service

  after_create :create_visits
  has_many :visit_groups, through: :arm
  has_many :visits, -> { includes(:visit_group).order("visit_groups.position") }, :dependent => :destroy

  accepts_nested_attributes_for :visits

  private
  def create_visits
    new_visit_columns = [:visit_group_id, :line_item_id, :research_billing_qty, :insurance_billing_qty, :effort_billing_qty]
    new_visit_values = []
    self.visit_groups.pluck(:id).each do |vg|
      new_visit_values << [vg, self.id, 0, 0, 0]
    end
     Visit.import new_visit_columns, new_visit_values, {validate: true}
  end

  delegate  :name,
            :cost,
            to: :service
end
