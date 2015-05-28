require "rails_helper"

RSpec.describe Organization, type: :model do

  it { is_expected.to belong_to(:parent) }
  it { is_expected.to have_many(:services) }
  it { is_expected.to have_many(:sub_service_requests) }

  describe ".inclusive_child_services" do

    describe "Services present" do

      before { @organization = create(:organization_with_child_organizations) }

      after { Service.destroy_all }

      describe "scope of :per_participant" do

        it "should only return per_participant Services" do
          Service.update_all one_time_fee: true
          Service.all.limit(10).each { |service| service.update_attribute :one_time_fee, false }

          expect(@organization.inclusive_child_services(:per_participant).length).to eq(10)
        end
      end

      describe "scope of :one_time_fee" do

        it "should only return one_time_fee Services" do
          Service.update_all one_time_fee: false
          Service.all.limit(10).each { |service| service.update_attribute :one_time_fee, true }

          expect(@organization.inclusive_child_services(:one_time_fee).length).to eq(10)
        end
      end

      it "should return an array of its Services and its child's Services" do
        expect(@organization.inclusive_child_services(:per_participant).length).to eq(39)
      end
    end

    context "Services not present" do

      it "should return an empty array" do
        organization = create(:organization_with_child_organizations)

        Service.destroy_all

        expect(organization.inclusive_child_services(:per_participant)).to eq([])
      end
    end
  end

  describe ".all_child_organizations" do

    context "child Organizations present" do

      it "should return an array of child Organizations" do
        organization = create(:organization_with_child_organizations)

        expect(organization.all_child_organizations.length).to eq(12)
      end
    end

    context "child Organizations not present" do

      it "should return an empty array" do
        organization = create(:organization)

        expect(organization.all_child_organizations).to eq([])
      end
    end
  end

  describe ".protocols" do

    context "Protocols present" do

      it "should return an array of Protocols" do
        organization        = create(:organization)
        sub_service_request = create(:sub_service_request, organization: organization)

        create(:protocol, sub_service_request: sub_service_request)

        expect(organization.protocols.count).to eq(1)
      end
    end

    context "no Protocols present" do

      it "should return an empty array" do
        organization    = create(:organization)
        service_request = create(:service_request)
        create(:sub_service_request, organization: organization, service_request: service_request)

        expect(organization.protocols).to eq([])
      end
    end
  end
end
