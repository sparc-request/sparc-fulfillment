# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

  factory :arm do
    protocol nil
    sparc_id
    sequence(:name) { |n| "#{Faker::App.name} #{n}" }
    visit_count 5
    subject_count 5

    trait :with_singe_line_item do
      after(:create) do |arm, evaluator|
        service = create(:service)

        create(:line_item, protocol: arm.protocol, arm: arm, service: service)
      end
    end

    trait :with_duplicate_line_item do
      after(:create) do |arm, evaluator|
        service = create(:service)

        create_list(:line_item, 3, protocol: arm.protocol, arm: arm, service: service)
      end
    end

    trait :with_line_items do
      after(:create) do |arm, evaluator|
        x = 3
        x.times do
          create(:line_item_with_fulfillments, protocol: arm.protocol, service: create(:service_with_one_time_fee), quantity_requested: 10) # one time fee
          create(:line_item, protocol: arm.protocol, arm: arm, service: create(:service)) # pppv
        end
      end
    end

    trait :with_only_per_patient_line_items do
      after(:create) do |arm, evaluator|
        5.times do
          create(:line_item, protocol: arm.protocol, arm: arm, service: create(:service)) # pppv
        end
      end
    end

    trait :with_visit_groups do
      after(:create) do |arm, evaluator|
        arm.visit_count.times do |n|
          create(:visit_group, arm: arm, position: n + 1)
        end
      end
    end

    trait :with_one_visit_group do
      after(:create) do |arm, evaluator|
        create(:visit_group, arm: arm)
        arm.update_attributes(visit_count: 1)
      end
    end

    trait :with_visits do
      after(:create) do |arm, evaluator|
        arm.visit_groups.each do |visit_group|
          arm.line_items.each do |line_item|
            create(:visit, line_item: line_item, visit_group: visit_group)
          end
        end
      end
    end

    trait :with_participant do
      after(:create) do |arm, evaluator|
        create(:participant_with_appointments, arm: arm, protocol: arm.protocol)
      end
    end

    trait :with_protocol do
      association :protocol
    end

    factory :arm_with_protocol, traits: [:with_protocol]
    factory :arm_with_single_service, traits: [:with_singe_line_item, :with_visit_groups, :with_visits, :with_participant]
    factory :arm_with_duplicate_services, traits: [:with_duplicate_line_item, :with_visit_groups, :with_visits, :with_participant]
    factory :arm_with_line_items, traits: [:with_line_items]
    factory :arm_with_visit_groups, traits: [:with_visit_groups]
    factory :arm_imported_from_sparc, traits: [:with_line_items, :with_visit_groups, :with_visits, :with_participant]
    factory :arm_with_only_per_patient_line_items, traits: [:with_only_per_patient_line_items, :with_visit_groups, :with_visits]
    factory :arm_with_one_visit_group, traits: [:with_one_visit_group]
  end
end
