require "rails_helper"

RSpec.describe Organization, type: :model do

  describe "#all_child_organizations" do

    context "child Organizations present" do

      it "should return an array of child Organizations" do
        institution_organization = create(:organization_institution)

        provider_organization = create(:provider_with_child_organizations)
        provider_organization.update_attribute(:parent_id, institution_organization.id)

        program_organization = create(:program_with_child_organizations)
        program_organization.update_attribute(:parent_id, provider_organization.id)

        core_organization = create(:organization_with_child_organizations)
        core_organization.update_attribute(:parent_id, program_organization.id)

        # 12 children a piece.

        # 12 provider children + 12 program children + 12 core children + program_organization + core_organizaiton
        expect(provider_organization.all_child_organizations.flatten.uniq.size).to eq(38)

        # 12 program children + 12 core children + core_organizaiton
        expect(program_organization.all_child_organizations.flatten.uniq.size).to eq(25)

        # 12 core children
        expect(core_organization.all_child_organizations.flatten.uniq.size).to eq(12)
      end
    end

    context "child Organizations not present" do

      it "should return an empty array" do
        institution_organization = create(:organization_institution)

        provider_organization = create(:provider_with_child_organizations)
        provider_organization.update_attribute(:parent_id, institution_organization.id)

        program_organization = create(:program_with_child_organizations)
        program_organization.update_attribute(:parent_id, provider_organization.id)

        organization_with_no_children = create(:organization)
        organization_with_no_children.update_attribute(:parent_id, program_organization.id)

        # 12 provider children + 12 program children + program_organization + organization_with_no_children
        expect(provider_organization.all_child_organizations.flatten.uniq.size).to eq(26)
        
        # 12 program children + organization_with_no_children
        expect(program_organization.all_child_organizations.flatten.uniq.size).to eq(13)

        # no children
        expect(organization_with_no_children.all_child_organizations).to eq([])
      end
    end
  end
end
