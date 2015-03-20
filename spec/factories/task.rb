FactoryGirl.define do

  factory :task do
    user
    assignee_id { FactoryGirl.create(:user).id }
    participant_name { Faker::Name.name }
    task_type { "Participant-level Task" }
    protocol_id { FactoryGirl.create(:protocol).id }
    visit_name { "Visit" + " #{rand(50)}" }
    arm_name { "Arm" + " #{rand(10)}" }
    task { Faker::Lorem.word }
    due_date Time.current
  end
end
