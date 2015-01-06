FactoryGirl.define do

  factory :visit_group do
    arm nil
    sequence :sparc_id do |n|
      Random.rand(9999) + n
    end
    sequence :name do |n|
      "Visit Group #{n}"
    end
  end
end
