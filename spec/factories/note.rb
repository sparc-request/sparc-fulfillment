FactoryGirl.define do

  factory :note do
    user_id nil
    kind 'note'

    trait :followup do
      kind 'followup'
    end

    factory :note_followup, traits: [:followup]
  end
end
