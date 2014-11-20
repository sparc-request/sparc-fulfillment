FactoryGirl.define do

  factory :line_item do
    arm nil
    service nil
    sparc_id 1
    sequence :name do |n|
      "LineItem #{n}"
    end
  end
end
