# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require "rails_helper"

RSpec.describe Identity, type: :model do

  it { is_expected.to have_one(:identity_counter) }

  it { is_expected.to have_many(:documents) }
  it { is_expected.to have_many(:project_roles) }
  it { is_expected.to have_many(:clinical_providers) }

  describe "#protocols" do

    context "Identity is clinical provider" do

      context "clinical provider is attached to organization with protocols" do

        it "should return an array of Protocols" do
          identity            = create(:identity)
          organization        = create(:organization_provider, children_count: 2, has_protocols: true)

          create(:clinical_provider, identity: identity, organization: organization.children.first)
          create(:clinical_provider, identity: identity, organization: organization.children.last)
   
          protocol_ids = []
          organization.children.map{ |child| protocol_ids << child.protocols.map(&:id) }
          

          expect(identity.protocols.map(&:id).flatten.sort).to eq(protocol_ids.flatten)
        end
      end

      context "clinical provider is attached to organization without protocols, but children do have protocols" do

        it "should return an empty array" do
            identity            = create(:identity)
            organization        = create(:organization_provider, children_count: 2, has_protocols: true)

            create(:clinical_provider, identity: identity, organization: organization)
            expect(identity.protocols.map(&:id).flatten.sort).to eq([])
        end
      end

      context "clinicalprovider is attached to organization without protocols" do
        it "should return an empty array" do
          identity            = create(:identity)
          organization        = create(:organization_provider, children_count: 2)

          create(:clinical_provider, identity: identity, organization: organization)

          expect(identity.protocols).to eq([])
        end
      end
    end

    context "Identity is super user" do
      context "super_user is attached to organization without protocols, but children do have protocols" do
        it "should return an array of Protocols attached to children" do
          identity            = create(:identity)
          organization        = create(:organization_provider, children_count: 2, has_protocols: true)

          create(:super_user, identity: identity, organization: organization)

          protocol_ids = []
          organization.children.map{ |child| protocol_ids << child.protocols.map(&:id) }

          expect(identity.protocols.map(&:id).flatten.sort).to eq(protocol_ids.flatten)
        end
      end

      context "super_user is attached to organization with protocols" do
        it "should return an array of Protocols attached to organizations" do 
          identity            = create(:identity)
          organization        = create(:organization_provider, children_count: 2, has_protocols: true)

          create(:super_user, identity: identity, organization: organization.children.first)
          create(:super_user, identity: identity, organization: organization.children.last)
   
          protocol_ids = []
          organization.children.map{ |child| protocol_ids << child.protocols.map(&:id) }
          

          expect(identity.protocols.map(&:id).flatten.sort).to eq(protocol_ids.flatten)
        end
      end

      context "super_user is attached to organization without protocols and children that do not have protocols" do
        it "should return an empty array" do
          identity            = create(:identity)
          organization        = create(:organization_provider, children_count: 2)

          create(:super_user, identity: identity, organization: organization)

          expect(identity.protocols).to eq([])
        end
      end
    end

    context "Identity is super user at program level and clinical provider at provider level" do
      it "should return protocols attached to provider org and protocols attached to program org and all children org protocols" do

        identity                  = create(:identity)
        institution_organization  = create(:organization_institution, children_count: 2, has_protocols: true)
        provider_organization     = create(:organization_provider, parent_id: institution_organization.id, children_count: 2, has_protocols: true)
        program_organization      = create(:organization_program, parent_id: provider_organization.id, children_count: 2, has_protocols: true)

        create(:clinical_provider, identity: identity, organization: provider_organization)
        create(:super_user, identity: identity, organization: program_organization)

        protocol_ids = []
        # clinical_provider is attached at provider level, provider organization has a protocol attached
        protocol_ids << provider_organization.protocols.map(&:id)
        # super user is attached at program level, include protocol attached to program
        protocol_ids << program_organization.protocols.map(&:id)
        # super user is attached at program level, include all the core orgs (children) protocols
        program_organization.children.map{ |child| protocol_ids << child.protocols.map(&:id) }
        
        expect(identity.protocols.map(&:id).flatten.sort).to eq(protocol_ids.flatten.sort)
      end
    end

    context "Identity is neither super user or clinical provider" do
      it "should return an empty array" do
        identity        = create(:identity)
        organization    = create(:organization_program, children_count: 2)

        sub_service_request = create(:sub_service_request, organization: organization)
        protocol            = create(:protocol, sub_service_request: sub_service_request)

        create(:project_role_pi, identity: identity, protocol: protocol)

        expect(identity.protocols).to eq([])
      end
    end
  end

  describe '.identity_counter' do

    context "IdentityCounter exists" do

      it "should not create a new IdentityCounter" do
        identity = create(:identity_with_counter)
        expect(identity.identity_counter).to be
        expect(IdentityCounter.count).to eq(1)
      end
    end

    context "IdentityCounter does not exist" do

      it "should create an IdentityCounter if it does not exist" do
        identity = create(:identity)
        expect(identity.identity_counter).to be
        expect(IdentityCounter.count).to eq(1)
      end
    end
  end

  describe '.tasks_count' do

    it "should be delegated to identity_counter" do
      identity = create(:identity)
      expect(identity.tasks_count).to be(0)
    end
  end
end
