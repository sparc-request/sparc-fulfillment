FactoryGirl.define do

  factory :participant do
    arm nil
    protocol nil
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    middle_initial { Faker::Base.letterify('?') }
    mrn { Faker::Number.number(8) }
    status { Participant::STATUS_OPTIONS.sample }
    date_of_birth "08-16-1996"
    gender { Participant::GENDER_OPTIONS.sample }
    ethnicity { Participant::ETHNICITY_OPTIONS.sample }
    race { Participant::RACE_OPTIONS.sample }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zipcode { Faker::Base.numerify('#####') }
    phone { Faker::Base.numerify('###-###-####') }

    trait :with_protocol do
      protocol
    end

    trait :with_appointments do
      after(:create) do | participant, evaluator|
        participant.arm.visit_groups.each do |vg|
          create(:appointment,
                  participant: participant,
                  visit_group: vg,
                  name: vg.name,
                  visit_group_position: vg.position,
                  arm_id: vg.arm_id,
                  position: participant.appointments.count + 1)
        end
      end
    end

    trait :with_completed_appointments do
      after(:create) do | participant, evaluator|
        participant.arm.visit_groups.each do |visit_group|
          create(:appointment,
                  participant: participant,
                  visit_group: visit_group,
                  name: visit_group.name,
                  visit_group_position: visit_group.position,
                  arm_id: visit_group.arm_id,
                  position: participant.appointments.count + 1,
                  completed_date: Time.current + visit_group.id.days)
        end
      end
    end

    factory :participant_with_protocol, traits: [:with_protocol]
    factory :participant_with_appointments, traits: [:with_appointments]
    factory :participant_with_completed_appointments, traits: [:with_completed_appointments]
  end
end
