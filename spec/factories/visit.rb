FactoryGirl.define do

  factory :visit do
    line_item nil
    visit_group nil
    sequence :sparc_id do |n|
      Random.rand(9999) + n
    end
    research_billing_qty 0
    insurance_billing_qty 0
    effort_billing_qty 0
  end
end
