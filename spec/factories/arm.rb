FactoryGirl.define do

  factory :arm do
    protocol nil
    sparc_id
    sequence(:name) { |n| "Arm #{n}" }
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

    trait :with_visits do
      after(:create) do |arm, evaluator|
        arm.visit_groups.each do |visit_group|
          arm.line_items.each do |line_item|
            create(:visit, line_item: line_item, visit_group: visit_group)
          end
        end
      end
    end

    trait :with_participant do
      after(:create) do |arm, evaluator|
        create(:participant, arm: arm, protocol: arm.protocol)
      end
    end

    factory :arm_with_line_items, traits: [:with_line_items]
    factory :arm_with_visit_groups, traits: [:with_visit_groups]
    factory :arm_imported_from_sparc, traits: [:with_line_items, :with_visit_groups, :with_visits, :with_participant]
  end
end
