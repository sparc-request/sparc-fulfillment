FactoryGirl.define do

  factory :appointment do
    visit_group nil
    participant nil
    start_date Time.current

    trait :with_procedures do
      after(:create) do |appointment, evaluator|
        service = create(:service)
        3.times do
          create(:procedure_with_notes, appointment: appointment, service_id: service.id, service_name: service.name, sparc_core_id: service.sparc_core_id, sparc_core_name: service.sparc_core_id)
        end
      end
    end

    factory :appointment_with_procedures, traits: [:with_procedures]
  end
end

