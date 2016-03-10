require 'rails_helper'

RSpec.describe InvoiceReportGroupedOptions do

  describe 'group_organizations' do

    context 'cores' do
      it 'a;lskdfj' do
        provider_with_protocols = create(:provider_with_protocols)
        program_with_protocols = create(:program_with_protocols)
        core_with_protocols = create(:core_with_protocols)

        organizations = [
          provider_with_protocols,
          program_with_protocols,
          core_with_protocols,
        ]
    
        binding.pry
      end 
    end
  end
end