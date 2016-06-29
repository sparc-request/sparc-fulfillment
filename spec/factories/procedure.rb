FactoryGirl.define do

  factory :procedure do
    appointment nil
    visit nil

    trait :insurance_billing_qty do
      billing_type 'insurance_billing_qty'
    end

    trait :research_billing_qty do
      billing_type 'research_billing_qty'
    end

    trait :complete do
      status 'complete'
      completed_date Date.today.strftime('%m/%d/%Y')
    end

    trait :incomplete do
      status 'incomplete'
      completed_date nil
      incompleted_date Date.today.strftime('%m/%d/%Y')
    end

    trait :follow_up do
      status 'follow_up'
      completed_date nil
      after(:create) do |procedure, evaluator|
        create(:task, assignable: procedure)
      end
    end

    trait :unstarted do
    end

    trait :with_notes do
      after(:create) do |procedure, evaluator|
        create_list(:note, 3, notable: procedure)
      end
    end

    trait :with_task do
      after(:create) do |procedure, evaluator|
        create(:task, assignable: procedure)
      end
    end

    factory :procedure_insurance_billing_qty_with_notes, traits: [:insurance_billing_qty, :with_notes]
    factory :procedure_research_billing_qty_with_notes, traits: [:research_billing_qty, :with_notes]
    factory :procedure_complete, traits: [:complete]
    factory :procedure_incomplete, traits: [:incomplete]
    factory :procedure_with_notes, traits: [:with_notes]
    factory :procedure_follow_up, traits: [:follow_up]
  end
end
