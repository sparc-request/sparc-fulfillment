FactoryGirl.define do

  factory :service, aliases: [:service_created_by_sparc] do
    sparc_id
    sequence(:name) { |n| "Service #{n}" }
    sequence(:cost)
    description 'Description'
    abbreviation 'Abbreviation'
  end
end
