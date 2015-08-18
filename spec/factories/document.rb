FactoryGirl.define do

  factory :document do
    sequence(:title) { |n| "Document #{n}" }
  	documentable_id nil
  	documentable_type nil

    trait :with_csv_file do
      original_filename "file.csv"
      content_type 'text/csv'
      after :create do |document, evaluator|
        File.open(document.path, "w") do |file|
          file.write("a, b, c")
        end
      end
    end

    trait :of_protocol_report do
     documentable_type "Protocol"
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

    factory :document_with_csv_file, traits: [:with_csv_file]
    factory :document_of_protocol_report, traits: [:of_protocol_report]
  end
end
