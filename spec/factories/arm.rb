FactoryGirl.define do

  factory :arm do
    protocol nil
    sparc_id 1
    sequence :name do |n|
      "Protocol #{n}"
    end
  end
end
