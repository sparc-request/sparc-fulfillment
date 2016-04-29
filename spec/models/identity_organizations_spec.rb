require 'rails_helper'

RSpec.describe IdentityOrganizations do

  describe '#fulfillment_organizations_with_protocols' do
    context "Identity is super user at provider level" do
      context "Identity is clinical_provider at institution level" do
        it "should return organizations for super_users and clinical_providers that have protocols" do
          identity                 = create(:identity)
          institution_organization = create(:organization_institution, has_protocols: true, children_count: 2)
          provider_organization    = create(:organization_provider, parent_id: institution_organization.id, has_protocols: true, children_count: 2)
          program_organization     = create(:organization_program, parent_id: provider_organization.id, has_protocols: true, children_count: 2)
          
          #Create protocol attached to institution org
          institution_sub_service_request = create(:sub_service_request, organization: institution_organization)
          institution_protocol            = create(:protocol, sub_service_request: institution_sub_service_request)

          create(:clinical_provider, identity: identity, organization: institution_organization)
          create(:super_user, identity: identity, organization: provider_organization)

          orgs_with_protocols = []
          # institution org has an attached protocol
          orgs_with_protocols << institution_organization.id
          # provider organization does not have an attached protocol, but program children do
          provider_organization.children.map{ |child| orgs_with_protocols << child.id if child.protocols.any? }
           # program organization does not have an attached protocol, but core children do
          program_organization.children.map{ |child| orgs_with_protocols << child.id if child.protocols.any? }


          expect(IdentityOrganizations.new(identity.id).fulfillment_organizations_with_protocols.map(&:id)).to eq(orgs_with_protocols.flatten.sort)
        end
      end
    end
  end

  describe '#super_user_protocols' do
    context "Identity is a super user at the program level" do

      it "should return protocols under program organization" do
        identity                 = create(:identity)
        institution_organization = create(:organization_institution, has_protocols: true, children_count: 2)
        provider_organization    = create(:organization_provider, parent_id: institution_organization.id, has_protocols: true, children_count: 2)
        program_organization     = create(:organization_program, parent_id: provider_organization.id, has_protocols: true, children_count: 2)

        create(:super_user, identity: identity, organization: program_organization)

        protocol_ids = []
        program_organization.children.map{ |child| protocol_ids << child.protocols.map(&:id) }
     
        expect(IdentityOrganizations.new(identity.id).super_user_protocols.map(&:id)).to eq(protocol_ids.flatten.sort)
      end
    end
    context "Identity is not a super user" do
      it "should return an empty array" do
        identity                 = create(:identity)
        institution_organization = create(:organization_institution, has_protocols: true, children_count: 2)
        provider_organization    = create(:organization_provider, parent_id: institution_organization.id, has_protocols: true, children_count: 2)
        program_organization     = create(:organization_program, parent_id: provider_organization.id, has_protocols: true, children_count: 2)

        create(:clinical_provider, identity: identity, organization: program_organization)
     
        expect(IdentityOrganizations.new(identity.id).super_user_protocols).to eq([])
      end
    end
  end

  describe '#clinical_provider_protocols' do
    context "Identity is a clinical_provider at the program level" do
      it "should return protocol attached to the program organization" do
        identity                 = create(:identity)
        institution_organization = create(:organization_institution, has_protocols: true, children_count: 2)
        provider_organization    = create(:organization_provider, parent_id: institution_organization.id, has_protocols: true, children_count: 2)
        program_organization     = create(:organization_program, parent_id: provider_organization.id, has_protocols: true, children_count: 2)

        create(:clinical_provider, identity: identity, organization: program_organization)

        program_sub_service_request = create(:sub_service_request, organization: program_organization)
        program_protocol            = create(:protocol, sub_service_request: program_sub_service_request)

        expect(IdentityOrganizations.new(identity.id).clinical_provider_protocols.map(&:id)).to eq([program_protocol.id])
      end
    end

    context "Identity is not a clinical_provider" do
      it "should return an empty array" do
        identity                 = create(:identity)
        institution_organization = create(:organization_institution, has_protocols: true, children_count: 2)
        provider_organization    = create(:organization_provider, parent_id: institution_organization.id, has_protocols: true, children_count: 2)
        program_organization     = create(:organization_program, parent_id: provider_organization.id, has_protocols: true, children_count: 2)

        create(:super_user, identity: identity, organization: program_organization.children.first)
     
        expect(IdentityOrganizations.new(identity.id).clinical_provider_protocols).to eq([])
      end
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