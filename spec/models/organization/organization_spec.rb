require "rails_helper"

RSpec.describe Organization, type: :model do

  it { is_expected.to belong_to(:parent) }
  it { is_expected.to have_many(:services) }
  it { is_expected.to have_many(:sub_service_requests) }


  describe '#all_child_organizations' do

    it "should return all child organizations" do

      institution_organization = create(:organization_institution)

      provider_organization = create(:provider_with_3_child_orgs)
      provider_organization.update_attribute(:parent_id, institution_organization.id)

      program_organization = create(:program_with_3_child_orgs)
      program_organization.update_attribute(:parent_id, provider_organization.id)

      core_organization = create(:core_with_3_child_orgs)
      core_organization.update_attribute(:parent_id, program_organization.id)

      expect(program_organization.all_child_organizations.map(&:id).length).to eq(7)
    end
  end

  describe '#child_orgs_with_protocols' do

    it "should return all child organizations WITH protocols" do

      institution_organization = create(:organization_institution)

      provider_organization = create(:provider_with_3_child_orgs)
      provider_organization.update_attribute(:parent_id, institution_organization.id)

      program_organization = create(:program_with_3_child_orgs)
      program_organization.update_attribute(:parent_id, provider_organization.id)

      core_organization = create(:core_with_3_child_orgs)
      core_organization.update_attribute(:parent_id, program_organization.id)

      program_sub_service_request = create(:sub_service_request, organization: program_organization)
      program_protocol            = create(:protocol, sub_service_request: program_sub_service_request)

      expect(provider_organization.child_orgs_with_protocols.map(&:id)).to eq([program_organization.id])
    end
  end
end
