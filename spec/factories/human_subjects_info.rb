FactoryGirl.define do

  factory :human_subjects_info do
    protocol nil
    irb_approval_date 1.day.from_now
    irb_expiration_date 2.days.from_now
  end
end
