FactoryGirl.define do

  factory :service, aliases: [:service_created_by_sparc] do
    sparc_id 1
    sequence :name do |n|
      "Service #{n}"
    end
    description 'description'
  end
end
