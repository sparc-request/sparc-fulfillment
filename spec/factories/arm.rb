FactoryGirl.define do

  factory :arm do
    protocol nil
    sparc_id
    sequence(:name) { Faker::App.name }
    visit_count { rand(3..15) }
    subject_count 5

    trait :with_line_items do
      after(:create) do |arm, evaluator|
        x = rand(12)+1
        x.times do
          create(:line_item_otf, protocol: arm.protocol, service: create(:service_of_otf_with_components))
          create(:line_item, protocol: arm.protocol, arm: arm, service: create(:service))
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
        create(:participant_with_appointments, arm: arm, protocol: arm.protocol)
      end
    end

    factory :arm_with_line_items, traits: [:with_line_items]
    factory :arm_with_visit_groups, traits: [:with_visit_groups]
    factory :arm_imported_from_sparc, traits: [:with_line_items, :with_visit_groups, :with_visits, :with_participant]
  end
end
