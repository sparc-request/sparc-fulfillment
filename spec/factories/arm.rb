FactoryGirl.define do

  factory :arm do
    protocol nil
    sparc_id 1
    subject_count 1
    visit_count 1
    sequence :name do |n|
      "Protocol #{n}"
    end
    visit_count 5
    subject_count 5
  end
end
