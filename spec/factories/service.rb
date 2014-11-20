FactoryGirl.define do

  factory :service do
    sparc_id 1
    sequence :name do |n|
      "Service #{n}"
    end
    description 'description'
  end
end
