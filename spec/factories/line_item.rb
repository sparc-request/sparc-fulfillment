FactoryGirl.define do

  factory :line_item do
    arm nil
    service nil
    sequence :sparc_id do |n|
      Random.rand(9999) + n
    end
  end
end
