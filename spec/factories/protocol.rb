FactoryGirl.define do

  factory :protocol, aliases: [:protocol_created_by_sparc] do
    sparc_id Random.rand(1..9999)
    sparc_sub_service_request_id 1
    title 'Fake'
    short_title 'Moaner'
    sponsor_name 'Heidi'
    udak_project_number '5'
    start_date Date.today
    end_date Date.today
    recruitment_start_date Date.today
    recruitment_end_date Date.today
    irb_status 'Complete'
    irb_approval_date Date.today
    irb_expiration_date Date.today
    stored_percent_subsidy 0.0
    study_cost 500
    status 'Complete'
  end
end
