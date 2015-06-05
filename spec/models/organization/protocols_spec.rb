require "rails_helper"

RSpec.describe Organization, type: :model do

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
