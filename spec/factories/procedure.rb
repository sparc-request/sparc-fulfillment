FactoryGirl.define do

  factory :procedure, aliases: [:procedure_incomplete] do
    appointment nil
    visit nil
    follow_up_date Time.now

    trait :complete do
      completed_date Time.current
    end

    trait :with_notes do
      after(:create) do |procedure, evaluator|
        create_list(:note, 3, procedure: procedure)
      end
    end

    factory :procedure_complete, traits: [:complete]
    factory :procedure_with_notes, traits: [:with_notes]
  end
end
