require 'rails_helper'

RSpec.describe InvoiceReportGroupedOptions do

  describe 'collect_grouped_options' do

    context 'provider, program, and core all have protocols' do


      it 'should return an array with providers, programs, and cores' do
        provider_with_protocols = create(:provider_with_protocols)
        program_with_protocols = create(:program_with_protocols)
        core_with_protocols = create(:core_with_protocols)

        provider_name = provider_with_protocols.name
        provider_id = ("#{provider_with_protocols.id}").to_i

        program_name = program_with_protocols.name
        program_id = ("#{program_with_protocols.id}").to_i

        core_name = core_with_protocols.name
        core_id = ("#{core_with_protocols.id}").to_i

        organizations = [
          provider_with_protocols,
          program_with_protocols,
          core_with_protocols,
        ]
    
        expect(InvoiceReportGroupedOptions.new(organizations).collect_grouped_options).to eq([["Providers", [["#{provider_name}", provider_id]]], ["Programs", [["#{program_name}", program_id]]], ["Cores", [["#{core_name}", core_id]]]])
     
      end 
    end

    context 'program, and core all have organizations with protocols' do


      it 'should return an array with only programs and cores' do
        
        program_with_protocols = create(:program_with_protocols)
        core_with_protocols = create(:core_with_protocols)

        program_name = program_with_protocols.name
        program_id = ("#{program_with_protocols.id}").to_i

        core_name = core_with_protocols.name
        core_id = ("#{core_with_protocols.id}").to_i

        organizations = [
          program_with_protocols,
          core_with_protocols,
        ]
    
        expect(InvoiceReportGroupedOptions.new(organizations).collect_grouped_options).to eq([["Programs", [["#{program_name}", program_id]]], ["Cores", [["#{core_name}", core_id]]]])
     
      end 
    end
  end
end