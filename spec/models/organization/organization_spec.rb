require "rails_helper"

RSpec.describe Organization, type: :model do
  it { is_expected.to belong_to(:parent) }
  it { is_expected.to have_many(:services) }
  it { is_expected.to have_many(:sub_service_requests) }
  it { is_expected.to have_many(:protocols) }
  it { is_expected.to have_many(:pricing_setups) }
  it { is_expected.to have_many(:non_process_ssrs_children) }
  it { is_expected.to have_many(:super_users) }
  it { is_expected.to have_many(:clinical_providers) }
  it { is_expected.to have_many(:children) }

  describe '#all_child_organizations' do
    context "organizations with children" do
      before :each do
        # Creates a parent organization at the institution level with n = 2 provider children organizations
        @institution_organization = create(:organization_institution, children_count: 2)
        # Creates a provider organization whose parent is institution_organization who has n = 2 program children
        @provider_organization = create(:organization_provider, children_count: 2, parent_id: @institution_organization.id )
        # Creates a program organization whose parent is provider_organization who has n = 2 core children
        @program_organization = create(:organization_program, children_count: 2, parent_id: @provider_organization.id )
      end 

      it "should return all child organizations for institution" do
        institution_organization_children_ids = [
                                                  @institution_organization.children.map(&:id),
                                                  @provider_organization.children.map(&:id),
                                                  @program_organization.children.map(&:id)
                                                ].flatten

        expect(@institution_organization.all_child_organizations.map(&:id).sort).to eq(institution_organization_children_ids)
      end

      it "should return all child organizations for provider" do
        provider_organization_children_ids = [
                                              @provider_organization.children.map(&:id),
                                              @program_organization.children.map(&:id)
                                            ].flatten

        expect(@provider_organization.all_child_organizations.map(&:id).sort).to eq(provider_organization_children_ids)
      end

      it "should return all child organizations for program" do
        program_organization_children_ids = [ @program_organization.children.map(&:id) ].flatten

        expect(@program_organization.all_child_organizations.map(&:id).sort).to eq(program_organization_children_ids)
      end
    end
    context "organizations with no children" do
      it "should return an empty array for program with no children" do
        program_organization = create(:organization_program)
        expect(program_organization.all_child_organizations.map(&:id).sort).to eq([])
      end
    end
  end

  describe '#child_orgs_with_protocols' do

    context "children organizations with protocols" do
      before :each do
        # Creates a parent organization at the institution level with n = 2 provider children organizations with protocols
        @institution_organization = create(:organization_institution, children_count: 2, has_protocols: true)
        # Creates a provider organization whose parent is institution_organization who has n = 2 program children with protocols
        @provider_organization = create(:organization_provider, children_count: 2, parent_id: @institution_organization.id, has_protocols: true)
        # Creates a program organization whose parent is provider_organization who has n = 2 core children with protocols
        @program_organization = create(:organization_program, children_count: 2, parent_id: @provider_organization.id, has_protocols: true )
      end 

      it "should return all child organizations for institution with protocols" do
        
        institution_organization_children_ids = []
        @institution_organization.children.map { |child| institution_organization_children_ids << child.id if child.protocols.any? }
        @provider_organization.children.map { |child| institution_organization_children_ids << child.id if child.protocols.any? }
        @program_organization.children.map { |child| institution_organization_children_ids << child.id if child.protocols.any? }

        institution_organization_children_ids.compact.flatten                               

        expect(@institution_organization.child_orgs_with_protocols.map(&:id).sort).to eq(institution_organization_children_ids)
      end

      it "should return all child organizations for provider" do
        provider_organization_children_ids = []
        @provider_organization.children.map { |child| provider_organization_children_ids << child.id if child.protocols.any? }
        @program_organization.children.map { |child| provider_organization_children_ids << child.id if child.protocols.any? }
        

        expect(@provider_organization.child_orgs_with_protocols.map(&:id).sort).to eq(provider_organization_children_ids)
      end

      it "should return all child organizations for program" do
        program_organization_children_ids = []
        @program_organization.children.map { |child| program_organization_children_ids << child.id if child.protocols.any? }

        expect(@program_organization.child_orgs_with_protocols.map(&:id).sort).to eq(program_organization_children_ids)
      end
    end

    context "children organizations with no protocols" do
      it "should return an empty array for organization with two children that have no protocols " do
        program_organization_with_children_with_no_protocols = create(:organization_program, children_count: 2)
        expect(program_organization_with_children_with_no_protocols.child_orgs_with_protocols.map(&:id).sort).to eq([])
      end
    end
  end
end
