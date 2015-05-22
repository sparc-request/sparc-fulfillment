FactoryGirl.define do

  factory :protocol, aliases: [:protocol_complete] do
    sparc_id
    title { Faker::Company.catch_phrase }
    short_title { Faker::Company.catch_phrase }
    sponsor_name { Faker::Company.name }
    udak_project_number { Faker::Company.duns_number }
    start_date { Faker::Date.between(10.years.ago, 3.days.ago) }
    end_date Time.current
    recruitment_start_date { Faker::Date.between(10.years.ago, 3.days.ago) }
    recruitment_end_date Time.current
    irb_approval_date { Faker::Date.between(10.years.ago, 3.days.ago) }
    irb_expiration_date Time.current
    stored_percent_subsidy 0.0
    study_cost { Faker::Number.number(8) }
    status { Protocol::STATUSES.sample }

    trait :imported_from_sparc do
      after(:create) do |protocol, evaluator|
        create_list(:arm_imported_from_sparc, 3, protocol: protocol)
      end
    end

    trait :with_pi do
      after(:create) do |protocol, evaluator|
        create(:project_role_pi, protocol: protocol)
      end
    end

    trait :with_coordinator do
      after(:create) do |protocol, evaluator|
        create(:project_role_coordinator, protocol: protocol)
      end
    end

    trait :with_coordinators do
      after(:create) do |protocol, evaluator|
        create_list(:project_role_coordinator, 3, protocol: protocol)
      end
    end

    trait :with_sub_service_request do
      after(:create) do |protocol, evaluator|
        sub_service_request = create(:sub_service_request)
        protocol.update_attribute(:sparc_sub_service_request_id, sub_service_request.id)
      end
    end

    factory :protocol_imported_from_sparc, traits: [:imported_from_sparc, :with_pi, :with_coordinators, :with_sub_service_request]
    factory :protocol_with_pi, traits: [:with_pi]
  end
end
