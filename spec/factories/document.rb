FactoryGirl.define do

  factory :document do |n|
    title "MyDocument"

    trait :with_csv_file do
      original_filename "file.csv"
      content_type 'text/csv'
      after :create do |document, evaluator|
        File.open(document.path, "w") do |file|
          file.write("a, b, c")
        end
      end
    end

    trait :of_identity_report do
      documentable_type "Identity"
      documentable_id nil
      report_type "invoice_report"
      state "Completed"
      original_filename "file.csv"
      content_type 'text/csv'

      after :create do |document|
        identity = Identity.find(document.documentable_id)
        identity.identity_counter.update_attributes(unaccessed_documents_count: identity.unaccessed_documents_count + 1)
        File.open(document.path, "w"){ |file| file.write("a, b, c") }
      end
    end

    trait :of_protocol_report do
      documentable_type "Protocol"
      documentable_id nil
      report_type "study_schedule_report"
      state "Completed"
      original_filename "file.csv"
      content_type 'text/csv'

      after :create do |document|
        protocol = Protocol.find(document.documentable_id)
        protocol.update_attributes(unaccessed_documents_count: protocol.unaccessed_documents_count + 1)
        File.open(document.path, "w"){ |file| file.write("a, b, c") }
      end
    end

    trait :of_participant_report do
      documentable_type "Protocol"
      documentable_id nil
      report_type "participant_report"
      state "Completed"
      original_filename "file.csv"
      content_type 'text/csv'

      after :create do |document|
        protocol = Protocol.find(document.documentable_id)
        protocol.update_attributes(unaccessed_documents_count: protocol.unaccessed_documents_count + 1)
        File.open(document.path, "w"){ |file| file.write("a, b, c") }
      end
    end

    factory :document_with_csv_file, traits: [:with_csv_file]
    factory :document_of_identity_report, traits: [:of_identity_report]
    factory :document_of_protocol_report, traits: [:of_protocol_report]
    factory :document_of_participant_report, traits: [:of_participant_report]
  end
end
