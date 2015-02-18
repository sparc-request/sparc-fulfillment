FactoryGirl.define do

  factory :service, aliases: [:service_created_by_sparc] do
    sparc_id
    sequence(:name) { Faker::Commerce.product_name }
    sparc_core_id { rand(0..4) }
    sparc_core_name { ['Nexus', 'RCM', 'Something', 'Or Other', 'Wooo'][sparc_core_id] }
    sequence(:cost)
    description 'Description'
    abbreviation 'Abbreviation'
  end
end
