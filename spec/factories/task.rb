FactoryGirl.define do

  factory :task, aliases: [:task_incomplete] do
    identity
    assignee factory: :identity
    due_at "09/09/2025"
    body { Faker::Lorem.sentence }

    trait :complete do
      complete true
    end

    factory :task_complete, traits: [:complete]
  end
end
