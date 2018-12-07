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

  factory :protocol, aliases: [:protocol_complete] do
    sparc_id
    sub_service_request nil
    sponsor_name { Faker::Company.name }
    udak_project_number { Faker::Company.duns_number }
    start_date { Faker::Date.between(10.years.ago, 3.days.ago) }
    end_date Time.current
    recruitment_start_date { Faker::Date.between(10.years.ago, 3.days.ago) }
    recruitment_end_date Time.current
    study_cost { Faker::Number.number(8) }

    after(:create) do |protocol, evaluator|
      sparc_protocol = create(:sparc_protocol)
      protocol.update_attributes(sparc_id: sparc_protocol.id)
      create(:human_subjects_info, protocol_id: protocol.sparc_id)
    end

    trait :with_sub_service_request do
      sub_service_request factory: :sub_service_request_with_organization
    end

    trait :with_arm do
      after(:create) do |protocol, evaluator|
        create(:arm_imported_from_sparc, protocol: protocol)
      end
    end

    trait :with_arms do
      after(:create) do |protocol, evaluator|
        create_list(:arm_imported_from_sparc, 3, protocol: protocol)
      end
    end

    trait :with_arm_with_single_and_duplicate_services do
      after(:create) do |protocol, evaluator|
        create(:arm_with_single_and_duplicate_services, protocol: protocol)
      end
    end

    trait :with_pi do
      after(:create) do |protocol, evaluator|
        create(:project_role_pi, protocol_id: protocol.sparc_id)
      end
    end

    trait :with_coordinator do
      after(:create) do |protocol, evaluator|
        create(:project_role_coordinator, protocol_id: protocol.sparc_id)
      end
    end

    trait :with_coordinators do
      after(:create) do |protocol, evaluator|
        create_list(:project_role_coordinator, 3, protocol_id: protocol.sparc_id)
      end
    end

    trait :without_services do
      after(:create) do |protocol, evaluator|
        Service.delete_all
        protocol.line_items.delete_all
      end
    end

    factory :protocol_with_sub_service_request, traits: [:with_sub_service_request]
    factory :protocol_without_services, traits: [:with_pi,
                                                  :with_coordinators,
                                                  :with_sub_service_request,
                                                  :without_services]
    factory :protocol_with_pi, traits: [:with_pi]
    factory :protocol_imported_from_sparc, traits: [:with_arms,
                                                    :with_pi,
                                                    :with_coordinators,
                                                    :with_sub_service_request]
    factory :protocol_with_single_service, traits: [:with_arm_with_single_service, :with_pi, :with_coordinators, :with_sub_service_request]
    factory :protocol_with_duplicate_services, traits: [:with_arm_with_duplicate_services, :with_pi, :with_coordinators, :with_sub_service_request]
  end
end
