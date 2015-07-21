require "rails_helper"

RSpec.describe Organization, type: :model do

  describe "find in organization tree" do

    let!(:ssr)      { create(:sub_service_request)}
    let!(:protocol) { create(:protocol, sub_service_request: ssr) }
    let!(:provider) { create(:organization_provider, name: 'Celery Man') }
    let!(:program)  { create(:organization_program, name: 'Tayne', parent: provider) }
    let!(:core)     { create(:organization_core, name: 'Oyster', parent: program) }

    before :each do
      ssr.update_attributes(organization: core)
    end

    context 'provider' do

      it "should return the provider's name if 'Provider' is passed in" do
        expect(protocol.organization.find_in_organization_tree('Provider')).to eq('Celery Man')
      end
    end

    context 'program' do

      it "should return the program's name if 'Program' is passed in" do
        expect(protocol.organization.find_in_organization_tree('Program')).to eq('Tayne')
      end
    end

    context 'core' do

      it "should return the core's name if Core' is passed in" do
        expect(protocol.organization.find_in_organization_tree('Core')).to eq('Oyster')
      end

      it "should rescue to '-' if split/notify is at the program level" do
        ssr.update_attributes(organization: program)
        expect(protocol.organization.find_in_organization_tree('Core')).to eq('-')
      end
    end
  end
end