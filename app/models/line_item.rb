class LineItem < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :arm
  belongs_to :service

  has_many :visit_groups, through: :arm
  has_many :visits, -> { includes(:visit_group).order("visit_groups.position") }, dependent: :destroy

  after_create :create_visits

  accepts_nested_attributes_for :visits

  delegate  :name,
            :cost,
            :sparc_core_id,
            :sparc_core_name,
            to: :service

  private

  def create_visits
    new_visit_columns = [:visit_group_id, :line_item_id, :research_billing_qty, :insurance_billing_qty, :effort_billing_qty]
    new_visit_values  = []

    self.visit_groups.pluck(:id).each do |vg|
      new_visit_values << [vg, self.id, 0, 0, 0]
    end

    Visit.import new_visit_columns, new_visit_values, { validate: true }
  end
end
