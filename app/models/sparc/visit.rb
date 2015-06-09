class Sparc::Visit < ActiveRecord::Base
  
  include SparcShard

  belongs_to :line_items_visit
  belongs_to :visit_group

  def total_quantity
    research_billing_qty + insurance_billing_qty
  end
end
