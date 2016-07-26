require 'rails_helper'

RSpec.describe IdentityOrganizations do

  describe '#fulfillment_organizations_with_protocols', truncation: true do
    it "should return organizations for clinical_providers that have protocols" do
      identity    = create(:identity)
      institution = create(:organization, type: 'Institution')
      provider    = create(:organization, type: 'Provider', parent_id: institution.id)
      program     = create(:organization, type: 'Program', parent_id: provider.id)
      core        = create(:organization, type: 'Core', parent_id: program.id, process_ssrs: true)

      ssr = create(:sub_service_request, organization: core)
      create(:protocol, sub_service_request_id: ssr.id)

      create(:clinical_provider, identity: identity, organization: core)

      expect(IdentityOrganizations.new(identity.id).fulfillment_organizations_with_protocols.map(&:id)).to eq([core.id])
    end

    it "shouldn't return organizations for clinical_providers that don't have protocols" do
      identity    = create(:identity)
      institution = create(:organization, type: 'Institution')
      provider    = create(:organization, type: 'Provider', parent_id: institution.id)
      program     = create(:organization, type: 'Program', parent_id: provider.id)
      core        = create(:organization, type: 'Core', parent_id: program.id, process_ssrs: true)

      core2        = create(:organization, type: 'Core', parent_id: program.id, process_ssrs: true)

      ssr = create(:sub_service_request, organization: core)
      create(:protocol, sub_service_request_id: ssr.id)

      create(:clinical_provider, identity: identity, organization: core2)

      expect(IdentityOrganizations.new(identity.id).fulfillment_organizations_with_protocols.map(&:id)).to eq([])
    end

    it "should return organizations for super_users that have protocols" do
      identity    = create(:identity)
      institution = create(:organization, type: 'Institution')
      provider    = create(:organization, type: 'Provider', parent_id: institution.id)
      program     = create(:organization, type: 'Program', parent_id: provider.id)
      core        = create(:organization, type: 'Core', parent_id: program.id, process_ssrs: true)

      ssr = create(:sub_service_request, organization: core)
      create(:protocol, sub_service_request_id: ssr.id)

      create(:super_user, identity: identity, organization: provider)

      expect(IdentityOrganizations.new(identity.id).fulfillment_organizations_with_protocols.map(&:id)).to eq([core.id])
    end

    it "shouldn't return organizations for super_users that don't have protocols" do
      identity    = create(:identity)
      institution = create(:organization, type: 'Institution')
      provider    = create(:organization, type: 'Provider', parent_id: institution.id)
      program     = create(:organization, type: 'Program', parent_id: provider.id)
      core        = create(:organization, type: 'Core', parent_id: program.id, process_ssrs: true)

      provider2   = create(:organization, type: 'Provider', parent_id: institution.id)

      ssr = create(:sub_service_request, organization: core)
      create(:protocol, sub_service_request_id: ssr.id)

      create(:super_user, identity: identity, organization: provider2)

      expect(IdentityOrganizations.new(identity.id).fulfillment_organizations_with_protocols.map(&:id)).to eq([])
    end

    it "should return organizations for clinical_providers and super_users that have protocols" do
      identity    = create(:identity)
      institution = create(:organization, type: 'Institution')
      provider    = create(:organization, type: 'Provider', parent_id: institution.id)
      program     = create(:organization, type: 'Program', parent_id: provider.id)
      core        = create(:organization, type: 'Core', parent_id: program.id, process_ssrs: true)

      provider2   = create(:organization, type: 'Provider', parent_id: institution.id)
      program2    = create(:organization, type: 'Program', parent_id: provider2.id)
      core2       = create(:organization, type: 'Core', parent_id: program2.id, process_ssrs: true)

      ssr = create(:sub_service_request, organization: core)
      create(:protocol, sub_service_request_id: ssr.id)

      ssr2 = create(:sub_service_request, organization: core2)
      create(:protocol, sub_service_request_id: ssr2.id)

      create(:super_user, identity: identity, organization: provider)
      create(:clinical_provider, identity: identity, organization: core2)

      expect(IdentityOrganizations.new(identity.id).fulfillment_organizations_with_protocols.map(&:id)).to eq([core.id, core2.id])
    end
  end

  describe '#fulfillment_access_protocls', truncation: true do
    it "should return protocols for which you are a super_user" do
      identity    = create(:identity)
      institution = create(:organization, type: 'Institution')
      provider    = create(:organization, type: 'Provider', parent_id: institution.id)
      program     = create(:organization, type: 'Program', parent_id: provider.id)
      core        = create(:organization, type: 'Core', parent_id: program.id, process_ssrs: true)

      ssr = create(:sub_service_request, organization: core)
      p = create(:protocol, sub_service_request_id: ssr.id)

      create(:super_user, identity: identity, organization: provider)

      expect(IdentityOrganizations.new(identity.id).fulfillment_access_protocols.map(&:id)).to eq([p.id])
    end

    it "should return protocols for which you are a clinical_provider" do
      identity    = create(:identity)
      institution = create(:organization, type: 'Institution')
      provider    = create(:organization, type: 'Provider', parent_id: institution.id)
      program     = create(:organization, type: 'Program', parent_id: provider.id)
      core        = create(:organization, type: 'Core', parent_id: program.id, process_ssrs: true)

      ssr = create(:sub_service_request, organization: core)
      p = create(:protocol, sub_service_request_id: ssr.id)

      create(:clinical_provider, identity: identity, organization: core)

      expect(IdentityOrganizations.new(identity.id).fulfillment_access_protocols.map(&:id)).to eq([p.id])
    end

    it "should return protocols for which you are a clinical_provider and a super_user" do
      identity    = create(:identity)
      institution = create(:organization, type: 'Institution')
      provider    = create(:organization, type: 'Provider', parent_id: institution.id)
      program     = create(:organization, type: 'Program', parent_id: provider.id)
      core        = create(:organization, type: 'Core', parent_id: program.id, process_ssrs: true)

      provider2   = create(:organization, type: 'Provider', parent_id: institution.id)
      program2    = create(:organization, type: 'Program', parent_id: provider2.id)
      core2       = create(:organization, type: 'Core', parent_id: program2.id, process_ssrs: true)

      ssr = create(:sub_service_request, organization: core)
      p1 = create(:protocol, sub_service_request_id: ssr.id)

      ssr2 = create(:sub_service_request, organization: core2)
      p2 = create(:protocol, sub_service_request_id: ssr2.id)

      create(:super_user, identity: identity, organization: provider)
      create(:clinical_provider, identity: identity, organization: core2)

      expect(IdentityOrganizations.new(identity.id).fulfillment_access_protocols.map(&:id)).to eq([p1.id, p2.id])
    end

    it "should not return protocols for which you are not a super_user" do
      identity    = create(:identity)
      institution = create(:organization, type: 'Institution')
      provider    = create(:organization, type: 'Provider', parent_id: institution.id)
      program     = create(:organization, type: 'Program', parent_id: provider.id)
      core        = create(:organization, type: 'Core', parent_id: program.id, process_ssrs: true)

      provider2   = create(:organization, type: 'Provider', parent_id: institution.id)

      ssr = create(:sub_service_request, organization: core)
      create(:protocol, sub_service_request_id: ssr.id)

      create(:super_user, identity: identity, organization: provider2)

      expect(IdentityOrganizations.new(identity.id).fulfillment_access_protocols.map(&:id)).to eq([])
    end

    it "should not return protocols for which you are not a clinical_provider" do
      identity    = create(:identity)
      institution = create(:organization, type: 'Institution')
      provider    = create(:organization, type: 'Provider', parent_id: institution.id)
      program     = create(:organization, type: 'Program', parent_id: provider.id)
      core        = create(:organization, type: 'Core', parent_id: program.id, process_ssrs: true)

      core2        = create(:organization, type: 'Core', parent_id: program.id, process_ssrs: true)

      ssr = create(:sub_service_request, organization: core)
      create(:protocol, sub_service_request_id: ssr.id)

      create(:clinical_provider, identity: identity, organization: core2)

      expect(IdentityOrganizations.new(identity.id).fulfillment_access_protocols.map(&:id)).to eq([])
    end
  end
end
