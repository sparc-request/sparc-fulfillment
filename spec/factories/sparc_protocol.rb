FactoryGirl.define do

  factory :sparc_protocol, class: Sparc::Protocol do
    title { Faker::Company.catch_phrase }
    short_title { Faker::Company.catch_phrase }
  end
end
