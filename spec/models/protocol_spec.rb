require 'rails_helper'

RSpec.describe Protocol, type: :model do

  it { is_expected.to belong_to(:sub_service_request) }

  it { is_expected.to have_one(:organization) }

  it { is_expected.to have_many(:arms).dependent(:destroy) }
  it { is_expected.to have_many(:line_items).dependent(:destroy) }
  it { is_expected.to have_many(:participants).dependent(:destroy) }
  it { is_expected.to have_many(:project_roles).dependent(:destroy) }
  it { is_expected.to have_many(:service_requests) }

  context 'class methods' do

    describe '#delete' do

      it 'should not permanently delete the record' do
        protocol = create(:protocol)

        protocol.delete

        expect(protocol.persisted?).to be
      end
    end

    describe 'callbacks' do

      it 'should callback :update_via_faye after save' do
        protocol = create(:protocol_imported_from_sparc)

        expect(protocol).to callback(:update_faye).after(:save)
      end

      it 'should callback :update_via_faye after destroy' do
        protocol = create(:protocol_imported_from_sparc)

        expect(protocol).to callback(:update_faye).after(:destroy)
      end
    end
  end

  context 'instance methods' do

    describe 'subsidy_committed' do

      it 'should return the correct amount in cents' do
        protocol = create(:protocol_imported_from_sparc)

        protocol.update_attributes(study_cost: 5000, stored_percent_subsidy: 10.00)

        expect(protocol.subsidy_committed).to eq(500)
      end
    end

    describe 'pi' do

      it 'should return the primary investigator of the protocol' do
        protocol = create(:protocol_imported_from_sparc)

        expect(protocol.pi).to eq protocol.project_roles.where(role: "primary-pi").first.identity
      end
    end

    describe 'coordinators' do

      it 'should return the coordinators of the protocol' do
        protocol = create(:protocol_imported_from_sparc)

        expect(protocol.coordinators).to eq protocol.project_roles.where(role: "research-assistant-coordinator").map(&:identity)
      end
    end

    describe 'one_time_fee_line_items' do

      it 'should return the line items of type one time fee of the protocol' do
        protocol = create(:protocol_imported_from_sparc)

        expect(protocol.one_time_fee_line_items).to eq protocol.line_items.includes(:service).where(:services => {:one_time_fee => true})
      end
    end
  end
end
