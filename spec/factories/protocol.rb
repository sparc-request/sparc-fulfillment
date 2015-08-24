FactoryGirl.define do

  factory :protocol, aliases: [:protocol_complete] do
    sparc_id
    sub_service_request nil
    sponsor_name { Faker::Company.name }
    udak_project_number { Faker::Company.duns_number }
    start_date { Faker::Date.between(10.years.ago, 3.days.ago) }
    end_date Time.current
    recruitment_start_date { Faker::Date.between(10.years.ago, 3.days.ago) }
    recruitment_end_date Time.current
    stored_percent_subsidy 0.0
    study_cost { Faker::Number.number(8) }

    after(:create) do |protocol, evaluator|
      sparc_protocol = create(:sparc_protocol)
      protocol.update_attributes(sparc_id: sparc_protocol.id)
      create(:human_subjects_info, protocol_id: protocol.sparc_id)
    end

    trait :with_sub_service_request do
      sub_service_request factory: :sub_service_request_with_organization
    end

    trait :with_arm do
      after(:create) do |protocol, evaluator|
        create(:arm_imported_from_sparc, protocol: protocol)
      end
    end

    trait :with_arms do
      after(:create) do |protocol, evaluator|
        create_list(:arm_imported_from_sparc, 3, protocol: protocol)
      end
    end

    trait :with_arm_with_single_and_duplicate_services do
      after(:create) do |protocol, evaluator|
        create(:arm_with_single_and_duplicate_services, protocol: protocol)
      end
    end

    trait :with_pi do
      after(:create) do |protocol, evaluator|
        create(:project_role_pi, protocol_id: protocol.sparc_id)
      end
    end

    trait :with_coordinator do
      after(:create) do |protocol, evaluator|
        create(:project_role_coordinator, protocol_id: protocol.sparc_id)
      end
    end

    trait :with_coordinators do
      after(:create) do |protocol, evaluator|
        create_list(:project_role_coordinator, 3, protocol_id: protocol.sparc_id)
      end
    end

    trait :without_services do
      after(:create) do |protocol, evaluator|
        Service.delete_all
      end
    end

    factory :protocol_with_sub_service_request, traits: [:with_sub_service_request]
    factory :protocol_without_services, traits: [:with_pi,
                                                  :with_coordinators,
                                                  :with_sub_service_request,
                                                  :without_services]
    factory :protocol_with_pi, traits: [:with_pi]
    factory :protocol_imported_from_sparc, traits: [:with_arms,
                                                    :with_pi,
                                                    :with_coordinators,
                                                    :with_sub_service_request]
    factory :protocol_with_single_service, traits: [:with_arm_with_single_service, :with_pi, :with_coordinators, :with_sub_service_request]
    factory :protocol_with_duplicate_services, traits: [:with_arm_with_duplicate_services, :with_pi, :with_coordinators, :with_sub_service_request]
  end
end
