FactoryGirl.define do

  factory :procedure do
    appointment nil
    visit nil
    follow_up_date "09-09-2009"

    trait :complete do
      status 'complete'
      completed_date Time.current
    end

    trait :incomplete do
      status 'incomplete'
      completed_date nil
    end

    trait :with_notes do
      after(:create) do |procedure, evaluator|
        create_list(:note, 3, notable: procedure)
      end
    end

    factory :procedure_complete, traits: [:complete]
    factory :procedure_incomplete, traits: [:incomplete]
    factory :procedure_with_notes, traits: [:with_notes]
  end
end
