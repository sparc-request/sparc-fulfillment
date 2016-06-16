FactoryGirl.define do

  factory :visit_group do
    arm nil
    sparc_id
    sequence(:position, 1)
    sequence(:day) { |n| 7 * n + 1 } # days spaced a week apart
    sequence(:name) { |n| "Visit Group #{n}" }

    trait :with_arm do
      arm
    end

    factory :visit_group_with_arm, traits: [:with_arm]
  end
end
