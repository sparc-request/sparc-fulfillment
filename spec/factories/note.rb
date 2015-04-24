FactoryGirl.define do

  factory :note do
    user_id nil
    kind 'note'

    trait :followup do
      kind 'followup'
    end

    trait :reason do
      kind 'reason'
    end

    factory :note_followup, traits: [:followup]
    factory :note_reason, traits: [:reason]
  end
end
