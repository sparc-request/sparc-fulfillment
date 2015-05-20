require 'rails_helper'

RSpec.describe Protocol, type: :model do

  it { is_expected.to have_many(:arms).dependent(:destroy) }
  it { is_expected.to have_many(:line_items).dependent(:destroy) }
  it { is_expected.to have_many(:participants).dependent(:destroy) }
  it { is_expected.to have_many(:project_roles).dependent(:destroy) }

  context 'class methods' do

    describe '#delete' do

      it 'should not permanently delete the record' do
        protocol = create(:protocol)

        protocol.delete

        expect(protocol.persisted?).to be
      end
    end

    describe 'callbacks' do

      before(:each) do
        @protocol = create(:protocol)
      end

      it 'should callback :update_via_faye after save' do
        expect(@protocol).to callback(:update_faye).after(:save)
      end

      it 'should callback :update_via_faye after destroy' do
        expect(@protocol).to callback(:update_faye).after(:destroy)
      end
    end
  end

  context 'instance methods' do

    before(:each) do
      @protocol = create(:protocol_imported_from_sparc)
    end

    describe 'subsidy_committed' do

      it 'should return the correct amount in cents' do
        @protocol.update_attributes(study_cost: 5000, stored_percent_subsidy: 10.00)
        expect(@protocol.subsidy_committed).to eq(500)
      end
    end

    describe 'pi' do

      it 'should return the primary investigator of the protocol' do
        expect(@protocol.pi).to eq @protocol.project_roles.where(role: "primary-pi").first.identity
      end
    end

    describe 'coordinators' do

      it 'should return the coordinators of the protocol' do
        expect(@protocol.coordinators).to eq @protocol.project_roles.where(role: "research-assistant-coordinator").map(&:identity)
      end
    end

    describe 'one_time_fee_line_items' do

      it 'should return the line items of type one time fee of the protocol' do
        expect(@protocol.one_time_fee_line_items).to eq @protocol.line_items.includes(:service).where(:services => {:one_time_fee => true})
      end
    end
  end
end
