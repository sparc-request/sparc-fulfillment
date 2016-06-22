require 'rails_helper'

RSpec.describe IdentityOrganizations do

  let(:identity) { create(:identity) }

  describe '#fulfillment_access_protocols' do
    it 'should return protocols for super users and clinical providers' do
      # Gets descendants of super user orgs as well, but not for clinical provider orgs
    end
  end

  describe '#fulfillment_organizations_with_protocols' do
    it "should return organizations for super users and clinical providers that have protocols" do
      # Gets descendants of super user orgs as well, but not for clinical provider orgs
      institution = create(:organization_institution)
      provider    = create(:organization_provider, parent: institution)
      program     = create(:organization_program, parent: provider)
      core        = create(:organization_core, parent: program)

      [institution, provider, core].each do |org|
        ssr = create(:sub_service_request, organization: org)
        create(:protocol, sub_service_request: ssr)
      end

      create(:clinical_provider, identity: identity, organization: institution)
      create(:super_user, identity: identity, organization: provider)

      orgs_with_protocols = []
      # institution has an attached protocol
      orgs_with_protocols << institution.id
      # provider has an attached protocol
      orgs_with_protocols << provider.id
      # program does not have a protocol but its child core does
      orgs_with_protocols << core.id

      binding.pry
      expect(IdentityOrganizations.new(identity.id).fulfillment_organizations_with_protocols.map(&:id)).to eq(orgs_with_protocols.flatten.sort)
    end
  end
end