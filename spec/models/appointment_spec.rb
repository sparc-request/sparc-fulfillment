require 'rails_helper'

RSpec.describe Appointment, type: :model do

  it { is_expected.to have_one(:protocol) }

  it { is_expected.to belong_to(:arm) }
  it { is_expected.to belong_to(:participant) }
  it { is_expected.to belong_to(:visit_group) }

  it { is_expected.to have_many(:procedures) }
  it { is_expected.to have_many(:appointment_statuses) }

  context 'instance methods' do
    describe 'validations' do
      it 'should validate properly' do
        protocol = create(:protocol)
        arm = create(:arm, protocol: protocol)
        participant = create(:participant, protocol: protocol, arm: arm)

        @appt = build(:appointment)
        expect(@appt.valid?).to be false

        @appt.participant_id = participant.id
        @appt.arm_id = arm.id
        @appt.name = "Visit 1"
        expect(@appt.valid?).to be true
      end
    end

    describe 'has_completed_procedures?' do
      before :each do
        protocol = create(:protocol)
        arm = create(:arm, protocol: protocol)
        participant = create(:participant, protocol: protocol, arm: arm)
        @appt = create(:appointment, arm: arm, name: "Visit 1", participant: participant)
        @proc1 = create(:procedure, :complete, appointment: @appt)
        @proc2 = create(:procedure, appointment: @appt)
      end

      it 'should return true when appt has completed procedures' do
        expect(@appt.has_completed_procedures?).to be true
      end

      it 'should return false when appt doesnt have completed procedures' do
        @proc1.update_attributes(status: "unstarted")
        expect(@appt.has_completed_procedures?).to be false
      end
    end

    describe 'initialize_procedures' do
      before :each do
        service1 = create(:service, name: 'A')
        service2 = create(:service, name: 'B')
        protocol = create(:protocol)
        arm = create(:arm, protocol: protocol)
        participant = create(:participant, protocol: protocol, arm: arm)
        line_item1 = create(:line_item, arm: arm, service: service1, protocol: protocol)
        line_item2 = create(:line_item, arm: arm, service: service2, protocol: protocol)
        visit_group = create(:visit_group, arm: arm)
        @visit_li1 = create(:visit, visit_group: visit_group, line_item: line_item1)
        @visit_li2 = create(:visit, visit_group: visit_group, line_item: line_item2)
        @appt = create(:appointment, visit_group: visit_group, participant: participant, arm: arm, name: visit_group.name)
      end

      it 'should not create a procedure if there is no visit for a line_item' do
        @visit_li1.destroy
        @visit_li2.update_attribute(:research_billing_qty, 1)
        @appt.initialize_procedures
        services_of_procedures = @appt.procedures.map{ |proc| proc.service_name }
        expect(services_of_procedures).to eq(['B'])
      end

      it 'should not create a procedure if the visit has no billing' do
        @appt.initialize_procedures
        services_of_procedures = @appt.procedures.map{ |proc| proc.service_name }
        expect(services_of_procedures).to eq([])
      end

      it 'should create procedures for each line_item' do
        @visit_li1.update_attribute(:research_billing_qty, 1)
        @visit_li2.update_attribute(:research_billing_qty, 1)
        @appt.initialize_procedures
        services_of_procedures = @appt.procedures.map{ |proc| proc.service_name }
        expect(services_of_procedures).to eq(['A','B'])
      end

      it 'should not create procedures for each line_item on a custom appointment' do
        @appt.update_attribute(:type, 'CustomAppointment')
        @appt.initialize_procedures
        expect(@appt.procedures.count).to eq 0
      end
    end
  end
end
