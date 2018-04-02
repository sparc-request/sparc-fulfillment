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

require 'rails_helper'

RSpec.describe ProfessionalOrganization, type: :model do
	it {is_expected.to belong_to(:parent)}

	describe '#parents' do

		context "professional organizations with parents" do

			before :each do
        		# Creates a parent professioanl organization at the institution level with n = 2 college children organizations
        		@institution_organization = create(:professional_organization_institution, children_count: 2)
        		# Creates a college professional organization whose parent is institution_organization with 2 department children institutions
        		@college_organization = create(:professional_organization_college, children_count: 2, parent_id: @institution_organization.id )
        		# Creates a department professional organization whose parent is college_organization with 2 division children institutions
        		@department_organization = create(:professional_organization_department, children_count: 2, parent_id: @college_organization.id )
      		end 

      it "should return all parents" do
        professional_org = create (:professional_organization_with_child_organizations)
        expect(@department_organization.parents).to eq([@institution_organization, @college_organization])
      end

			it "should return all parents with self" do
				professional_org = create (:professional_organization_with_child_organizations)
				expect(@department_organization.parents_and_self).to eq([@institution_organization, @college_organization, @department_organization])
			end
		end

		context "professional organizations with no parents" do
			it "should return an empty array" do
				professional_org = create(:professional_organization)
				expect(professional_org.parents).to eq([])
			end
		end
	end
end
