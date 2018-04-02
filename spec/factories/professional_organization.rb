# Copyright © 2011-2018 MUSC Foundation for Research Development
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
	
	factory :professional_organization do
		sequence(:name) { |n| "Fake Organization #{n}" }  # need this for fake data

		transient do
			children_count 0
		end

		after(:create) do |professional_organization, evaluator|
			evaluator.children_count.times do
				case (professional_organization.org_type)
					when "institution"
						create(:professional_organization_college, parent_id: professional_organization.id)
          when "college"
            create(:professional_organization_department, parent_id: professional_organization.id)
          when "department"
            create(:professional_organization_division, parent_id: professional_organization.id)
				end
			end
		end

		trait :institution do
			org_type "institution"
			parent_id nil
		end

		trait :college do
			org_type "college"
		end

		trait :department do
			org_type "department"
		end

		trait :division do
			org_type "division"
		end

		trait :with_child_organizations do
      after(:create) do |professional_organization, evaluator|
      	3.times do
      		child = create(:professional_organization, parent: professional_organization)
      		create_list(:professional_organization, 3, parent: child)
      		end
      	end
    end

    factory :professional_organization_institution, traits: [:institution]
    factory :professional_organization_college, traits: [:college]
    factory :professional_organization_department, traits: [:department]
    factory :professional_organization_division, traits: [:division]

		factory :professional_organization_with_child_organizations, traits: [:with_child_organizations]
	end
end