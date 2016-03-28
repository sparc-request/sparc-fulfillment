FactoryGirl.define do

  factory :visit_group do
    arm nil
    sparc_id
    day 1
    position 1
    sequence(:name) { |n| "Visit Group #{n}" }

    trait :with_arm do
      arm
    end

    factory :visit_group_with_arm, traits: [:with_arm]
  end
end
