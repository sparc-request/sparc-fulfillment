class Visit < ActiveRecord::Base
  self.per_page = 5

  acts_as_paranoid

  belongs_to :line_item
  belongs_to :visit_group

  def position
    visit_group.position
  end

  def is_checked?
    research_billing_qty > 0 || insurance_billing_qty > 0 || effort_billing_qty > 0
  end
end
