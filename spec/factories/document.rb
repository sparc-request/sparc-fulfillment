# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

FactoryBot.define do

  factory :document do |n|
    title { "MyDocument" }

    trait :with_csv_file do
      original_filename { "file.csv" }
      content_type { 'text/csv' }
      after :create do |document, evaluator|
        File.open(document.path, "w") do |file|
          file.write("a, b, c")
        end
      end
    end

    trait :of_identity_report do
      documentable_type { "Identity" }
      documentable_id { nil }
      report_type { "invoice_report" }
      state { "Completed" }
      original_filename { "file.csv" }
      content_type { 'text/csv' }

      after :create do |document|
        identity = Identity.find(document.documentable_id)
        identity.identity_counter.update_attributes(unaccessed_documents_count: identity.unaccessed_documents_count + 1)
        File.open(document.path, "w"){ |file| file.write("a, b, c") }
      end
    end

    trait :of_protocol_report do
      documentable_type { "Protocol" }
      documentable_id { nil }
      report_type { "study_schedule_report" }
      state { "Completed" }
      original_filename { "file.csv" }
      content_type { 'text/csv' }

      after :create do |document|
        protocol = Protocol.find(document.documentable_id)
        protocol.update_attributes(unaccessed_documents_count: protocol.unaccessed_documents_count + 1)
        File.open(document.path, "w"){ |file| file.write("a, b, c") }
      end
    end

    trait :of_participant_report do
      documentable_type { "Protocol" }
      documentable_id { nil }
      report_type { "participant_report" }
      state { "Completed" }
      original_filename { "file.csv" }
      content_type { 'text/csv' }

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
