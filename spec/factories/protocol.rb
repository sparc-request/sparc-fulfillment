FactoryGirl.define do

  factory :protocol do
    sparc_id 1
    sequence :title do |n|
      "Protocol #{n}"
    end
  end
end
