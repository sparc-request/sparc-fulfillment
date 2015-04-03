FactoryGirl.define do

  factory :task do
    user
    assignee factory: :user
    due_at Time.current + 1.day
    body { Faker::Lorem.sentence }
  end
end
