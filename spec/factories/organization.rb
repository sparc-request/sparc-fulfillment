# Copyright © 2011-2017 MUSC Foundation for Research Development~
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

FactoryGirl.define do

  factory :organization do
    sequence(:name) { |n| "Fake Organization #{n}" }  # need this for fake data
    process_ssrs false

    transient do
      children_count 0
      has_protocols false
    end

    after :create do |organization, evaluator|
      create_list(:pricing_setup, 3, organization: organization).each do |pricing_setup|
        pricing_setup.update_attributes(organization_id: organization.id)
      end

      evaluator.children_count.times do
        case(organization.type)
          when "Institution"
            if evaluator.has_protocols
              create(:organization_provider_with_protocols, parent_id: organization.id)
            else
              create(:organization_provider, parent_id: organization.id)
            end
          when "Provider"
            if evaluator.has_protocols
              create(:organization_program_with_protocols, parent_id: organization.id)
            else
              create(:organization_program, parent_id: organization.id)
            end
          when "Program"
            if evaluator.has_protocols
              create(:organization_core_with_protocols, parent_id: organization.id)
            else
              create(:organization_core, parent_id: organization.id)
            end
        end
      end
    end

    trait :institution do
      type "Institution"
      parent_id nil
    end

    trait :core do
      type "Core"
    end

    trait :program do
      type "Program"
    end

    trait :provider do
      type "Provider"
    end

    trait :with_protocols do
      after(:create) do |organization, evaluator|
        sub_service_request = create(:sub_service_request, organization: organization)
        create(:protocol, sub_service_request: sub_service_request)
      end
    end

    trait :with_services do
      after(:create) do |organization, evaluator|
        create_list(:service, 4, organization: organization)
        create_list(:service_with_one_time_fee, 4, organization: organization)
      end
    end

    trait :with_child_organizations do
      after(:create) do |organization, evaluator|
        3.times do
          child = create(:organization_with_services, parent: organization)

          create_list(:organization_with_services, 3, parent: child)
        end
      end
    end

    # trait :with_3_child_orgs do
    #   after(:create) do |organization, evaluator|
    #     3.times do
    #       create(:organization_with_services, parent: organization)
    #     end
    #   end
    # end

    factory :organization_institution, traits: [:institution]
    factory :organization_provider, traits: [:provider]
    factory :organization_program, traits: [:program]
    factory :organization_core, traits: [:core]


    factory :organization_institution_with_protocols, traits: [:institution, :with_protocols]
    factory :organization_provider_with_protocols, traits: [:provider, :with_protocols]
    factory :organization_program_with_protocols, traits: [:program, :with_protocols]
    factory :organization_core_with_protocols, traits: [:core, :with_protocols]
    
    
    factory :organization_with_protocols, traits: [:core, :with_protocols]

    factory :provider_with_protocols, traits: [:provider, :with_protocols]
    factory :program_with_protocols, traits: [:program, :with_protocols]
    factory :core_with_protocols, traits: [:core, :with_protocols]

    factory :organization_with_services, traits: [:core, :with_services]
    factory :provider_with_child_organizations_and_protocols, traits: [:with_protocols, :provider, :with_child_organizations]
    factory :provider_with_child_organizations, traits: [:with_services, :provider, :with_child_organizations]
    factory :program_with_child_organizations, traits: [:with_services, :program, :with_child_organizations]
    factory :organization_with_child_organizations, traits: [:with_services, :core, :with_child_organizations]

    # factory :provider_with_3_child_orgs, traits: [:with_services, :provider, :with_3_child_orgs]
    # factory :program_with_3_child_orgs, traits: [:with_services, :program, :with_3_child_orgs]
    # factory :core_with_3_child_orgs, traits: [:with_services, :core, :with_3_child_orgs]

  end
end
