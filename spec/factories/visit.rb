FactoryGirl.define do

  factory :visit do
    line_item nil
    visit_group nil
    sparc_id
    research_billing_qty 0
    insurance_billing_qty 0
    effort_billing_qty 0

    trait :with_complete_procedures do
      after(:create) do |visit, evaluator|
        create_list(:procedure_complete, 3, visit: visit)
      end
    end

    trait :with_incomplete_procedures do
      after(:create) do |visit, evaluator|
        create_list(:procedure_incomplete, 3, visit: visit)
      end
    end

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

    factory :visit_with_complete_and_incomplete_procedures, traits: [:with_complete_procedures, :with_incomplete_procedures]
    factory :visit_with_billing, traits: [:with_billing]
    factory :visit_without_billing, traits: [:without_billing]
  end
end
