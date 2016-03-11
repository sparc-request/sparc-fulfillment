require 'rails_helper'

RSpec.describe InvoiceReportGroupedOptions do

  describe 'collect_grouped_options' do

    context 'provider does not have protocols, while program and core do have protocols' do


      it 'should return an array with only programs and cores' do
        provider_with_no_protocols = create(:organization_provider)
        program_with_protocols = create(:program_with_protocols)
        core_with_protocols = create(:core_with_protocols)

        provider_name = provider_with_no_protocols.name
        provider_id = provider_with_no_protocols.id

        program_name = program_with_protocols.name
        program_id = program_with_protocols.id

        core_name = core_with_protocols.name
        core_id = core_with_protocols.id

        organizations = [
          provider_with_no_protocols,
          program_with_protocols,
          core_with_protocols,
        ]
    
        expect(InvoiceReportGroupedOptions.new(organizations).collect_grouped_options).to eq("[['Programs', [[#{program_name}, #{program_id}]], ['Cores', [[#{core_name}, #{core_id}]]]]")
    
        
      end 
    end
  end
end