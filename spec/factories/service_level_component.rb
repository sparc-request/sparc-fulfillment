FactoryGirl.define do

  factory :service_level_component do
    service nil
    sequence(:component) { |n| "Component #{n}" }
  end
end
