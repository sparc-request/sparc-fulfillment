FactoryGirl.define do

  factory :arm do
    protocol nil
    sequence :sparc_id do |n|
      Random.rand(9999) + n
    end
    sequence :name do |n|
      "Protocol #{n}"
    end
    visit_count 5
    subject_count 5
  end
end
