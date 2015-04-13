FactoryGirl.define do

  factory :line_item do
    arm nil
    service nil
    protocol nil
    sparc_id
    otf false

    trait :otf do
      otf true
      quantity { Faker::Number.number(3) }
      cost { Faker::Number.number(8) }
    end

    factory :line_item_otf, traits:[:otf]
  end
end
