FactoryGirl.define do

  factory :visit_group do
    arm nil
    sparc_id 1
    sequence :name do |n|
      "Visit Group #{n}"
    end
  end
end
