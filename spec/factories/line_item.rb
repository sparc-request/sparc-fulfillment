FactoryGirl.define do

  factory :line_item do
    arm nil
    service nil
    protocol nil
    sparc_id
    quantity_requested { Faker::Number.number(3) }
    quantity_type "Each"

    trait :otf do
      after(:create) do | line_item, evaluator|
        line_item.service.components.each do |sc|
          create(:component_of_line_item, composable_id: line_item.id, component: sc.component, position: sc.position)
        end
      end
    end

    factory :line_item_otf, traits:[:otf]
  end
end
