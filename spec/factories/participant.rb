FactoryGirl.define do

  factory :participant do
    arm nil
    protocol nil
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    mrn { Faker::Number.number(8) }
    status { Participant::STATUS_OPTIONS.sample }
    date_of_birth { Faker::Date.between(10.years.ago, Date.today) }
    gender { Participant::GENDER_OPTIONS.sample }
    ethnicity { Participant::ETHNICITY_OPTIONS.sample }
    race { Participant::RACE_OPTIONS.sample }
    address { Faker::Address.street_address }
    phone { Faker::Base.numerify('###-###-####') }

    trait :with_protocol do
      protocol
    end

    trait :with_appointments do
      after(:create) do | participant, evaluator|
        participant.arm.visit_groups.each do |vg|
          create(:appointment, participant: participant, visit_group: vg, name: vg.name, visit_group_position: vg.position)
        end
      end
    end

    factory :participant_with_protocol, traits: [:with_protocol]
    factory :participant_with_appointments, traits: [:with_appointments]
  end
end
