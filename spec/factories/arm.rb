FactoryGirl.define do

  factory :arm do
    protocol nil
    sequence :sparc_id do |n|
      Random.rand(9999) + n
    end
    sequence :name do |n|
      "Protocol #{n}"
    end
    visit_count 5
    subject_count 5

    trait :with_line_items do
      after(:create) do |arm, evaluator|
        service = create(:service)

        2.times do
          create(:line_item, arm: arm, service: service)
        end
      end
    end

    trait :with_visit_groups do
      after(:create) do |arm, evaluator|
        arm.visit_count.times do
          create(:visit_group, arm: arm)
        end
      end
    end

    factory :arm_with_line_items, traits: [:with_line_items]
    factory :arm_with_visit_groups, traits: [:with_visit_groups]
  end
end
