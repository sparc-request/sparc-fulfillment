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

        organizations = [
          provider_with_protocols,
          program_with_protocols,
          core_with_protocols,
        ]
    
        expect(InvoiceReportGroupedOptions.new(organizations).collect_grouped_options).to eq([["Providers", [["Gryffindor", provider_id]]], ["Programs", [["Slytherin", program_id]]], ["Cores", [["Hufflepuff", core_id]]]])
     
      end 
    end

    context 'program, and core all have organizations with protocols' do


      it 'should return an array with only programs and cores' do
        program_with_protocols = create(:organization_program, has_protocols: true, name: "Slytherin")
        core_with_protocols = create(:organization_core, has_protocols: true, name: "Hufflepuff")

        program_id = ("#{program_with_protocols.id}").to_i
        core_id = ("#{core_with_protocols.id}").to_i

        organizations = [
          program_with_protocols,
          core_with_protocols
        ]
    
        expect(InvoiceReportGroupedOptions.new(organizations).collect_grouped_options).to eq([["Programs", [["Slytherin", program_id]]], ["Cores", [["Hufflepuff", core_id]]]])
     
      end 
    end
  end
end