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

    factory :document_with_csv_file, traits: [:with_csv_file]
  end
end
