FactoryGirl.define do

  factory :identity do
    sequence(:email) { |n| "email#{n}@musc.edu" }
    sequence(:first_name) { |n| "Sally-#{n}"}
    last_name "Smith"
    password "password"
    time_zone "Eastern Time (US & Canada)"

    trait :with_counter do
      after :create do |identity|
        create(:identity_counter, identity: identity)
      end
    end

    factory :identity_with_counter, traits: [:with_counter]
  end
end
