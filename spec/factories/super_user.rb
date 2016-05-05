FactoryGirl.define do

  factory :super_user do
    identity nil
    organization nil

    trait :with_organization do
      organization
    end

    factory :super_user_with_organization, traits: [:with_organization]
  end
end
