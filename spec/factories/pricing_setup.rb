FactoryGirl.define do

  factory :pricing_setup do
    effective_date { Faker::Date.between(10.years.ago, 3.days.ago) }
    federal 100.00
    federal_rate_type "federal"
  end
end
