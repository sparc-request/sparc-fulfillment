require 'rails_helper'

RSpec.describe Procedure, type: :model do

  it { is_expected.to have_one(:protocol) }
  it { is_expected.to have_one(:arm) }
  it { is_expected.to have_one(:participant) }

  it { is_expected.to belong_to(:appointment) }
  it { is_expected.to belong_to(:visit) }
  it { is_expected.to belong_to(:core) }

  it { is_expected.to have_many(:notes) }
  it { is_expected.to have_many(:tasks) }

  it { is_expected.to accept_nested_attributes_for(:notes) }

  it { is_expected.to validate_inclusion_of(:status).in_array(Procedure::STATUS_TYPES) }

  context 'class methods' do

    before :each do
      @service = create(:service)
      protocol = create(:protocol)
      arm = create(:arm, protocol: protocol)
      @appointment = create(:appointment, arm: arm, participant_id: 5, name: "Super Arm")
    end

    describe 'service_name' do

      before(:each) do
        @procedure = create(:procedure, service: @service, appointment: @appointment)
      end

      it "should be equal to the service's name when the procedure is unstarted" do
        name = @service.name + '_'
        @service.update_attributes(name: @service.name + '_')
        expect(@procedure.service_name).to eq(name)
      end

      it "should be equal to the service's name at the time the procedure status changes from unstarted" do
        name = @service.name
        @procedure.update_attributes(status: 'complete')
        @service.update_attributes(name: @service.name + '_')
        expect(@procedure.service_name).to eq(name)
      end
    end

    describe '#delete' do

      it 'should not permanently delete the record' do
        procedure = create(:procedure)

        procedure.delete

        expect(procedure.reload.persisted?).to be
      end

      it 'should destroy the record if the status is unstarted' do
        procedure = create(:procedure)

        procedure.destroy

        expect(Procedure.count).to eq(0)
      end

      it 'should not destroy the record if the status is not unstarted' do
        (Procedure::STATUS_TYPES - ['unstarted']).each do |status|
          procedure = create(:procedure, status.to_sym)

          expect { procedure.destroy }.to raise_error(ActiveRecord::ActiveRecordError)
        end
      end
    end

    describe '.set_save_dependencies' do

      context 'status changed to complete' do

        before do
          to_status = 'complete'
          @procedures = (Procedure::STATUS_TYPES - [to_status]).map do |from_status|
            procedure = create(:procedure, from_status.to_sym)
            procedure.update_attributes(service_id: @service.id, status: to_status, appointment: @appointment)
            procedure # may not be necessary
          end
        end

        it 'should remove the incompleted date' do
          expect(@procedures.map(&:incompleted_date)).to_not be_any
        end

        it 'should set the completed date to today' do
          expect(@procedures.map(&:completed_date)).to be_all { |date| date == Date.today }
        end

        it 'should leave status set to complete' do
          expect(@procedures.map(&:status)).to be_all { |status| status == 'complete' }
        end
      end

      context 'status changed to incomplete' do

        before do
          to_status = 'incomplete'
          @procedures = (Procedure::STATUS_TYPES - [to_status]).map do |from_status|
            procedure = create(:procedure, from_status.to_sym)
            procedure.update_attributes(service_id: @service.id, status: to_status, appointment: @appointment)
            procedure # may not be necessary
          end
        end

        it 'should set the incompleted date to today' do
          expect(@procedures.map(&:incompleted_date)).to be_all { |date| date == Date.today }
        end

        it 'should remove the completed date' do
          expect(@procedures.map(&:completed_date)).to_not be_any
        end

        it 'should leave status set to incomplete' do
          expect(@procedures.map(&:status)).to be_all { |status| status == 'incomplete' }
        end
      end

      context 'status without task changed to unstarted or follow_up' do

        before do
          to_statuses = ['unstarted', 'follow_up']
          from_statuses = Procedure::STATUS_TYPES - to_statuses
          @procedures = from_statuses.product(to_statuses).map do |from_status, to_status|
            procedure = create(:procedure, from_status.to_sym)
            procedure.update_attributes(service_id: @service.id, status: to_status, appointment: @appointment)
            procedure
          end
        end

        it 'should remove completed dates' do
          expect(@procedures.map(&:completed_date)).to_not be_any
        end

        it 'should remove incompleted date' do
          expect(@procedures.map(&:incompleted_date)).to_not be_any
        end
      end

      context 'procedure has a task assigned to it' do

        before do
          to_statuses = ['unstarted', 'follow_up']
          from_statuses = Procedure::STATUS_TYPES - to_statuses

          @procedures = from_statuses.product(to_statuses).map do |from_status, to_status|
            procedure = create(:procedure, from_status.to_sym, :with_task)
            procedure.update_attributes(service_id: @service.id, status: to_status, appointment: @appointment)
            procedure
          end
        end

        it 'should remove completed date' do
          expect(@procedures.map(&:completed_date)).to_not be_any
        end

        it 'should remove incompleted date' do
          expect(@procedures.map(&:completed_date)).to_not be_any
        end

        it 'should set status to follow_up' do
          expect(@procedures.map(&:status)).to be_all { |status| status == 'follow_up' }
        end
      end
    end
  end
end
