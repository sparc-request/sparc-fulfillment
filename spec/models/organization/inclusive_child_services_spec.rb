require "rails_helper"

RSpec.describe Organization, type: :model do

  describe ".inclusive_child_services" do

    context "process_ssrs child Organizations present" do

      it "should only return Services of Organizations which are not process_ssrs" do
        organization  = create(:organization_with_services)
        child_1       = create(:organization_with_services, parent: organization)
        child_2       = create(:organization_with_services, parent: organization, process_ssrs: true)

        expect(organization.inclusive_child_services(:per_participant).length).to eq(8)
      end

      it "should only return Services of Organizations which are not process_ssrs" do
        organization  = create(:organization_with_services)
        child_1       = create(:organization_with_services, parent: organization)
        child_2       = create(:organization_with_services, parent: child_1, process_ssrs: true)

        expect(organization.inclusive_child_services(:per_participant).length).to eq(8)
      end
    end

    context "process_ssrs Organizations not present" do

      context "Services present" do

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
          expect(@organization.inclusive_child_services(:per_participant).length).to eq(52)
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
  end
end
