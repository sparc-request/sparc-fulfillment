FactoryGirl.define do

  factory :service, aliases: [:service_created_by_sparc] do
    sequence :sparc_id do |n|
      Random.rand(9999) + n
    end
    sequence :name do |n|
      "Service #{n}"
    end
    description 'description'
  end
end
