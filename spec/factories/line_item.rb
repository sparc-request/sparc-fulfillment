FactoryGirl.define do

  factory :line_item do
    arm nil
    service nil
    protocol nil
    sparc_id
    quantity_requested { Faker::Number.number(3) }
    quantity_type "Each"
  end
end
