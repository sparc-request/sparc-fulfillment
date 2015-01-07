FactoryGirl.define do

  factory :visit_group do
    arm nil
    day 1
    sequence :sparc_id do |n|
      Random.rand(9999) + n
    end
    sequence :name do |n|
      "Visit Group #{n}"
    end

    trait :with_arm do
      arm
    end

    factory :visit_group_with_arm, traits: [:with_arm]
  end
end
