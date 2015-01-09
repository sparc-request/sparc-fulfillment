FactoryGirl.define do

  factory :protocol, aliases: [:protocol_complete] do
    sparc_id
    sparc_sub_service_request_id 1
    title 'Title'
    short_title 'Short title'
    sponsor_name 'Sponsor name'
    udak_project_number '5'
    start_date Time.current
    end_date Time.current
    recruitment_start_date Time.current
    recruitment_end_date Time.current
    irb_status 'IRB status'
    irb_approval_date Time.current
    irb_expiration_date Time.current
    stored_percent_subsidy 0.0
    study_cost 500
    status 'Complete'

    trait :imported_from_sparc do
      after(:create) do |protocol, evaluator|
        create_list(:arm_imported_from_sparc, 3, protocol: protocol)
      end
    end

    factory :protocol_imported_from_sparc, traits: [:imported_from_sparc]
  end
end
