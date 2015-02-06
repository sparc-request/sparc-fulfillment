class Visit < ActiveRecord::Base
  self.per_page = 6

  acts_as_paranoid

  belongs_to :line_item
  belongs_to :visit_group

  has_many :procedures

  delegate :position, to: :visit_group

  def destroy
    procedures.untouched.map(&:destroy)

    super
  end

  def has_billing?
    research_billing_qty > 0 ||
      insurance_billing_qty > 0 ||
        effort_billing_qty > 0
  end
end
