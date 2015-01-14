FactoryGirl.define do

  factory :visit do
    line_item nil
    visit_group nil
    sparc_id
    research_billing_qty 0
    insurance_billing_qty 0
    effort_billing_qty 0

    trait :with_billing do
      research_billing_qty 1
      insurance_billing_qty 1
      effort_billing_qty 1
    end

    trait :without_billing do
      research_billing_qty 0
      insurance_billing_qty 0
      effort_billing_qty 0
    end

    factory :visit_with_billing, traits: [:with_billing]
    factory :visit_without_billing, traits: [:without_billing]
  end
end
