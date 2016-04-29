require 'rails_helper'

RSpec.describe IdentityOrganizations do

  # #fulfillment_access_protocols is tested in the Identity spec

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

  describe '#super_user_protocols' do

     it "should return protocols for super_users" do
      identity            = create(:identity)
      organization        = create(:organization)
      sub_service_request = create(:sub_service_request, organization: organization)
      protocol            = create(:protocol, sub_service_request: sub_service_request)
      protocol_id         = protocol.id

      create(:super_user, identity: identity, organization: organization)

      expect(IdentityOrganizations.new(identity.id).super_user_protocols.map(&:id)).to eq([protocol_id])
    end
  end

  describe '#clinical_provider_protocols' do

    it "should return protocols for clinical_providers" do
      identity            = create(:identity)
      organization        = create(:organization)
      sub_service_request = create(:sub_service_request, organization: organization)
      protocol            = create(:protocol, sub_service_request: sub_service_request)
      protocol_id         = protocol.id

      create(:clinical_provider, identity: identity, organization: organization)

      expect(IdentityOrganizations.new(identity.id).clinical_provider_protocols.map(&:id)).to eq([protocol_id])
    end
  end

  describe '#super_user_organizations_with_protocols' do

    before :each do
      @identity                 = create(:identity)
      @institution_organization = create(:organization_institution, has_protocols: true, children_count: 2)
      @provider_organization    = create(:organization_provider, parent_id: @institution_organization.id, has_protocols: true, children_count: 2)
      @program_organization     = create(:organization_program, parent_id: @provider_organization.id, has_protocols: true, children_count: 2)
    end

    context "institution org does not have protocols, but 2/3 provider children do" do
      context "provider org does not have protocols, but 2/3 program children do" do
        context "program org does not have protocols, but all core children do" do

          it "should return all child organizations with protocols attached" do
            create(:super_user, identity: @identity, organization: @institution_organization)

            orgs_with_protocols = []
            @institution_organization.children.map{ |child| orgs_with_protocols << child.id if child.protocols.any? }
            @provider_organization.children.map{ |child| orgs_with_protocols << child.id if child.protocols.any? }
            @program_organization.children.map{ |child| orgs_with_protocols << child.id if child.protocols.any? }
            
            expect(IdentityOrganizations.new(@identity.id).super_user_organizations_with_protocols.map(&:id)).to eq(orgs_with_protocols.flatten)
          end
        end
      end
    end

    context "institution org does not have protocols, but ALL provider children do" do
      context "program org does not have protocols, but all core children do" do

        it "should return provider and all child organizations" do
          # Create protocol attached to provider
          provider_sub_service_request = create(:sub_service_request, organization: @provider_organization)
          provider_protocol            = create(:protocol, sub_service_request: provider_sub_service_request)

          create(:super_user, identity: @identity, organization: @provider_organization)

          orgs_with_protocols = []
          orgs_with_protocols << @provider_organization.id
          @provider_organization.children.map{ |child| orgs_with_protocols << child.id if child.protocols.any? }
          @program_organization.children.map{ |child| orgs_with_protocols << child.id if child.protocols.any? }

          expect(IdentityOrganizations.new(@identity.id).super_user_organizations_with_protocols.map(&:id)).to eq(orgs_with_protocols.flatten)
        end
      end
    end
  end

  describe '#clinical_provider_organizations_with_protocols' do

    before :each do
      @identity                 = create(:identity)
      @institution_organization = create(:organization_institution, has_protocols: true, children_count: 2)
      @provider_organization    = create(:organization_provider, parent_id: @institution_organization.id, has_protocols: true, children_count: 2)
      @program_organization     = create(:organization_program, parent_id: @provider_organization.id, has_protocols: true, children_count: 2)
    end
    context "identity is clinical_provider" do
      context "clinical provider access at institution level" do
        context "institution org does not have protocols" do
          it "should return an empty array" do
            create(:clinical_provider, identity: @identity, organization: @institution_organization)

            expect(IdentityOrganizations.new(@identity.id).clinical_provider_organizations_with_protocols).to eq([])
          end
        end
      end

      context "clinical provider access at institution level" do
        context "institution org has protocols" do
          it "should return the institution id" do
            institution_sub_service_request = create(:sub_service_request, organization: @institution_organization)
            institution_protocol            = create(:protocol, sub_service_request: institution_sub_service_request)
            create(:clinical_provider, identity: @identity, organization: @institution_organization)

            expect(IdentityOrganizations.new(@identity.id).clinical_provider_organizations_with_protocols.map(&:id)).to eq([@institution_organization.id])
          end
        end
      end
    end
    context "identity is super_user" do
      context "super user access at institution level" do
        context "institution org has protocols" do
          it "should return an empty array" do
            institution_sub_service_request = create(:sub_service_request, organization: @institution_organization)
            institution_protocol            = create(:protocol, sub_service_request: institution_sub_service_request)
            create(:super_user, identity: @identity, organization: @institution_organization)

            expect(IdentityOrganizations.new(@identity.id).clinical_provider_organizations_with_protocols).to eq([])
          end
        end
      end
    end
  end
end