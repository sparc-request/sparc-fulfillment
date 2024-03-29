# Copyright © 2011-2023 MUSC Foundation for Research Development~
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

RSpec.describe InvoiceReportGroupedOptions do

  describe 'collect_grouped_options' do

    context 'provider, program, and core all have protocols' do


      it 'should return an array with providers, programs, and cores' do
        provider_with_protocols = create(:provider_with_protocols, name: "Gryffindor")
        program_with_protocols = create(:program_with_protocols, name: "Slytherin")
        core_with_protocols = create(:core_with_protocols, name: "Hufflepuff")

        provider_id = ("#{provider_with_protocols.id}").to_i
        program_id = ("#{program_with_protocols.id}").to_i
        core_id = ("#{core_with_protocols.id}").to_i

        provider_service = create(:service, name: "Harry's Service", organization: provider_with_protocols)
        program_service = create(:service, name: "Ron's Service", organization: program_with_protocols)
        core_service = create(:service, name: "Hermione's Service", organization: core_with_protocols)

        organizations = [
          provider_with_protocols,
          program_with_protocols,
          core_with_protocols,
        ]

        services = Service.where(organization_id: organizations.pluck(:id))
        
        expect(InvoiceReportGroupedOptions.new(organizations, 'organization').collect_grouped_options).to eq([["Providers", [[{:"data-content"=>"Gryffindor"}, provider_id]]], ["Programs", [[{:"data-content"=>"Slytherin"}, program_id]]], ["Cores", [[{:"data-content"=>"Hufflepuff"}, core_id]]]])

        expect(InvoiceReportGroupedOptions.new(services, 'service').collect_grouped_options_services).to match_array([
          [{:"data-content"=>"Harry's Service"}, provider_service.id],
          [{:"data-content"=>"Ron's Service"}, program_service.id],
          [{:"data-content"=>"Hermione's Service"}, core_service.id]
        ])

      end
    end

    context 'program, and core all have organizations with protocols' do


      it 'should return an array with only programs and cores' do
        program_with_protocols = create(:organization_program, has_protocols: true, name: "Slytherin")
        core_with_protocols = create(:organization_core, has_protocols: true, name: "Hufflepuff")

        program_id = ("#{program_with_protocols.id}").to_i
        core_id = ("#{core_with_protocols.id}").to_i

        program_service = create(:service, name: "Ron's Service", organization: program_with_protocols)
        core_service = create(:service, name: "Hermione's Service", organization: core_with_protocols)

        organizations = [
          program_with_protocols,
          core_with_protocols
        ]

        services = Service.where(organization_id: organizations.pluck(:id))

        expect(InvoiceReportGroupedOptions.new(organizations, 'organization').collect_grouped_options).to eq([["Programs", [[{:"data-content"=>"Slytherin"}, program_id]]], ["Cores", [[{:"data-content"=>"Hufflepuff"}, core_id]]]])

        expect(InvoiceReportGroupedOptions.new(services, 'service').collect_grouped_options_services).to match_array([
          [{:"data-content"=>"Ron's Service"}, program_service.id],
          [{:"data-content"=>"Hermione's Service"}, core_service.id]
        ])

      end
    end
  end
end
