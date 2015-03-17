FactoryGirl.define do

  factory :user do
    sequence(:email) { |n| "email#{n}@musc.edu" }
    sequence(:first_name) { |n| "Sally-#{n}"}
    last_name "Smith"
    password "password"
    time_zone "Eastern Time (US & Canada)"
  end
end
