FactoryGirl.define do

  factory :visit_group do
    arm nil
    sparc_id 1
    position 1
    day 1
    sequence :name do |n|
      "Visit Group #{n}"
    end
  end
end
