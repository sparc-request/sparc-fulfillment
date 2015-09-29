FactoryGirl.define do

  factory :arm do
    protocol nil
    sparc_id
    sequence(:name) { Faker::App.name }
    visit_count 5
    subject_count 5

    trait :with_singe_line_item do
      after(:create) do |arm, evaluator|
        service = create(:service)

        create(:line_item, protocol: arm.protocol, arm: arm, service: service)
      end
    end

    trait :with_duplicate_line_item do
      after(:create) do |arm, evaluator|
        service = create(:service)

        create_list(:line_item, 3, protocol: arm.protocol, arm: arm, service: service)
      end
    end

    trait :with_line_items do
      after(:create) do |arm, evaluator|
        x = 3
        x.times do
          create(:line_item_with_fulfillments, protocol: arm.protocol, service: create(:service_with_one_time_fee)) # one time fee
          create(:line_item, protocol: arm.protocol, arm: arm, service: create(:service)) # pppv
        end
      end
    end

    trait :with_only_per_patient_line_items do
      after(:create) do |arm, evaluator|
        5.times do
          create(:line_item, protocol: arm.protocol, arm: arm, service: create(:service)) # pppv
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

    trait :with_one_visit_group do
      after(:create) do |arm, evaluator|
        create(:visit_group, arm: arm)
        arm.update_attributes(visit_count: 1)
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

    factory :arm_with_single_service, traits: [:with_singe_line_item, :with_visit_groups, :with_visits, :with_participant]
    factory :arm_with_duplicate_services, traits: [:with_duplicate_line_item, :with_visit_groups, :with_visits, :with_participant]
    factory :arm_with_line_items, traits: [:with_line_items]
    factory :arm_with_visit_groups, traits: [:with_visit_groups]
    factory :arm_imported_from_sparc, traits: [:with_line_items, :with_visit_groups, :with_visits, :with_participant]
    factory :arm_with_only_per_patient_line_items, traits: [:with_only_per_patient_line_items, :with_visit_groups, :with_visits]
    factory :arm_with_one_visit_group, traits: [:with_one_visit_group]
  end
end
