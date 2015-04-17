FactoryGirl.define do

  factory :line_item do
    arm nil
    service nil
    protocol nil
    sparc_id

    trait :otf do
      quantity_requested { Faker::Number.number(3) }
      quantity_type "Each"
    end

    factory :line_item_otf, traits:[:otf]
  end
end
