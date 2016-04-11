require 'rails_helper'

RSpec.describe IdentityOrganizations do

  describe '#fulfillment_organizations_with_protocols' do

    it "should return organizations for super_users and clinical_providers that have protocols" do

      institution_organization = create(:organization_institution)

      provider_organization = create(:provider_with_child_organizations)
      provider_organization.update_attribute(:parent_id, institution_organization.id)

      program_organization = create(:program_with_child_organizations)
      program_organization.update_attribute(:parent_id, provider_organization.id)

      core_organization = create(:organization_with_child_organizations)
      core_organization.update_attribute(:parent_id, program_organization.id)

      identity               = create(:identity)
      program_sub_service_request = create(:sub_service_request, organization: program_organization)
      program_protocol            = create(:protocol, sub_service_request: program_sub_service_request)

      provider_sub_service_request = create(:sub_service_request, organization: provider_organization)
      provider_protocol            = create(:protocol, sub_service_request: provider_sub_service_request)

      core_sub_service_request = create(:sub_service_request, organization: core_organization)
      core_protocol            = create(:protocol, sub_service_request: core_sub_service_request)

      create(:super_user, identity: identity, organization: institution_organization)
      create(:clinical_provider, identity: identity, organization: core_organization)

      expect(IdentityOrganizations.new(identity.id).fulfillment_organizations_with_protocols.map(&:id)).to eq([core_organization.id,provider_organization.id, program_organization.id])
    end
  end

  describe '#fulfillment_organizations' do

    it "should return organizations for super_users and clinical_providers" do

      provider_organization = create(:provider_with_child_organizations)
      identity               = create(:identity)

      create(:super_user, identity: identity, organization: provider_organization)
      create(:clinical_provider, identity: identity, organization: provider_organization)

      all_children_ids = []

      provider_organization.children.each do |child|
        all_children_ids << child.children.map(&:id)
      end
      
      all_children_ids << provider_organization.id
      all_children_ids << provider_organization.children.map(&:id)

      expect(IdentityOrganizations.new(identity.id).fulfillment_organizations.map(&:id).sort).to eq(all_children_ids.flatten.sort)
    end
  end

  describe '#super_user_organizations(with_protocols = true)' do

    it "should return organizations that have super_user attached AND all the children organizations" do

      institution_organization = create(:organization_institution)

      provider_organization = create(:provider_with_child_organizations)
      provider_organization.update_attribute(:parent_id, institution_organization.id)

      program_organization = create(:program_with_child_organizations)
      program_organization.update_attribute(:parent_id, provider_organization.id)

      core_organization = create(:organization_with_child_organizations)
      core_organization.update_attribute(:parent_id, program_organization.id)

      identity               = create(:identity)
      program_sub_service_request = create(:sub_service_request, organization: program_organization)
      program_protocol            = create(:protocol, sub_service_request: program_sub_service_request)

      provider_sub_service_request = create(:sub_service_request, organization: provider_organization)
      provider_protocol            = create(:protocol, sub_service_request: provider_sub_service_request)

      create(:super_user, identity: identity, organization: institution_organization)

      expect(IdentityOrganizations.new(identity.id).super_user_organizations(with_protocols = true).map(&:id)).to eq([provider_organization.id, program_organization.id])
    end
  end

  describe '#clinical_provider_organizations(with_protocols = true)' do

    it "should return organizations that have a clinical provider on them AND have protocols." do
      identity               = create(:identity)
      cp_organization        = create(:organization)
      cp_sub_service_request = create(:sub_service_request, organization: cp_organization)
      cp_protocol            = create(:protocol, sub_service_request: cp_sub_service_request)

      create(:clinical_provider, identity: identity, organization: cp_organization)


      expect(IdentityOrganizations.new(identity.id).clinical_provider_organizations(with_protocols = true).first.id).to eq(cp_organization.id)
    end

    it "should return no organizations" do
      identity               = create(:identity)
      cp_organization        = create(:organization)

      create(:clinical_provider, identity: identity, organization: cp_organization)


      expect(IdentityOrganizations.new(identity.id).clinical_provider_organizations(with_protocols = true)).to eq([])
    end
  end

  describe '#clinical_provider_organizations(with_protocols = false)' do

    it "should return organizations that have a clinical provider on them" do
      identity               = create(:identity)
      cp_organization        = create(:organization)

      create(:clinical_provider, identity: identity, organization: cp_organization)


      expect(IdentityOrganizations.new(identity.id).clinical_provider_organizations.first.id).to eq(cp_organization.id)
    end

    it "should return organizations that have a clinical provider on them." do
      identity               = create(:identity)
      cp_organization        = create(:organization)
      cp_sub_service_request = create(:sub_service_request, organization: cp_organization)
      cp_protocol            = create(:protocol, sub_service_request: cp_sub_service_request)

      create(:clinical_provider, identity: identity, organization: cp_organization)


      expect(IdentityOrganizations.new(identity.id).clinical_provider_organizations.first.id).to eq(cp_organization.id)
    end
  end
end