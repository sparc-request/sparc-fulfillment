FactoryGirl.define do

  factory :appointment do
    visit_group nil
    participant nil
    arm nil
    sequence(:name) { |n| "Appointment #{n}" }

    trait :without_validations do
      to_create { |instance| instance.save(validate: false) }
    end

    trait :with_procedures do

      after(:create) do |appointment, evaluator|
        service = create(:service)

        appointment.visit_group.visits.each do |v|
          create(:procedure_research_billing_qty_with_notes,
                  appointment: appointment,
                  visit_id: v.id,
                  service_id: service.id,
                  service_name: service.name,
                  sparc_core_id: service.sparc_core_id,
                  sparc_core_name: service.sparc_core_id,
                  status: 'unstarted')
        end
      end
    end

    factory :appointment_with_procedures, traits: [:with_procedures], aliases: [:appointment_incomplete_with_procedures]
    factory :appointment_without_validations, traits: [:without_validations]
  end
end

