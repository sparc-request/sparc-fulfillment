FactoryGirl.define do

  factory :task do

    participant_name { Faker::Name.name }
    task_type { "Participant-level Task" }
    created_by { Faker::Name.name }
    protocol_id { rand(5000) }
    visit_name { "Visit" + " #{rand(50)}" }
    arm_name { "Arm" + " #{rand(10)}" }
    task { Faker::Lorem.word }
    assignment { Faker::Name.name }
    due_date Time.current
  end
end