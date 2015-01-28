FactoryGirl.define do

  factory :procedure do
   appointment_id nil
   follow_up_date Time.now

    trait :with_notes do
      after(:create) do |procedure, evaluator|
        create_list(:note, 3, procedure: procedure)
      end
    end
    factory :procedure_with_notes, traits: [:with_notes]
  end
end
