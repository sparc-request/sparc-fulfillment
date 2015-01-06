FactoryGirl.define do

  factory :participant do
    first_name "Honest"
    last_name "Abe"
    mrn 5
    arm nil
    status "Active"
    date_of_birth "2014-04-12"
    gender "Male"
    ethnicity "Not Hispanic or Latino"
    race "Caucasian"
    address "1 Lincoln Way"
    phone "123-456-7890"
  end
end