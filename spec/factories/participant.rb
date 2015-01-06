FactoryGirl.define do

  factory :participant do
    arm nil
    protocol nil
    first_name "Honest"
    last_name "Abe"
    mrn 5
    status "Active"
    date_of_birth "2014-04-12"
    gender "Male"
    ethnicity "Not Hispanic or Latino"
    race "Caucasian"
    address "1 Lincoln Way"
    phone "123-456-7890"

    trait :with_protocol do
      protocol
    end

    factory :participant_with_protocol, traits: [:with_protocol]
  end
end
