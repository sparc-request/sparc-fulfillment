FactoryGirl.define do

  sequence(:ldap_uid) { |n| "ldap#{n}@musc.edu" }

  factory :identity do
    email 'email@musc.edu'
    ldap_uid
    sequence(:first_name) { |n| "Sally-#{n}"}
    last_name "Smith"
    password "password"
    password_confirmation "password"
    time_zone "Eastern Time (US & Canada)"

    trait :with_counter do
      after :create do |identity|
        create(:identity_counter, identity: identity)
      end
    end

    factory :identity_with_counter, traits: [:with_counter]
  end
end
