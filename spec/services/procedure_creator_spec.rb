require "rails_helper"

RSpec.describe ProcedureCreator do

  describe 'initialize_procedures' do
    before :each do
      service1 = create(:service, name: 'A')
      service2 = create(:service, name: 'B')
      ssr = create(:sub_service_request)
      protocol = create(:protocol, sub_service_request: ssr)
      arm = create(:arm, protocol: protocol)
      participant = create(:participant)
      protocols_participant = create(:protocols_participant, arm: arm, protocol: protocol, participant: participant)
      line_item1 = create(:line_item, arm: arm, service: service1, protocol: protocol)
      line_item2 = create(:line_item, arm: arm, service: service2, protocol: protocol)
      visit_group = create(:visit_group, arm: arm)
      @visit_li1 = create(:visit, visit_group: visit_group, line_item: line_item1)
      @visit_li2 = create(:visit, visit_group: visit_group, line_item: line_item2)
      @appt = create(:appointment, visit_group: visit_group, protocols_participant: protocols_participant, arm: arm, name: visit_group.name, position: 1)
      @procedure_creator = ProcedureCreator.new(@appt)
    end

    it 'should not create a procedure if there is no visit for a line_item' do
      @visit_li1.destroy
      @visit_li2.update_attribute(:research_billing_qty, 1)
      @procedure_creator.initialize_procedures
      services_of_procedures = @appt.procedures.map{ |proc| proc.service_name }
      expect(services_of_procedures).to eq(['B'])
    end

    it 'should not create a procedure if the visit has no billing' do
      @procedure_creator.initialize_procedures
      services_of_procedures = @appt.procedures.map{ |proc| proc.service_name }
      expect(services_of_procedures).to eq([])
    end

    it 'should create procedures for each line_item' do
      @visit_li1.update_attribute(:research_billing_qty, 1)
      @visit_li2.update_attribute(:research_billing_qty, 1)
      @procedure_creator.initialize_procedures
      services_of_procedures = @appt.procedures.map{ |proc| proc.service_name }
      expect(services_of_procedures).to eq(['A','B'])
    end

    it 'should not create procedures for each line_item on a custom appointment' do
      @appt.update_attribute(:type, 'CustomAppointment')
      @procedure_creator.initialize_procedures
      expect(@appt.procedures.count).to eq 0
    end
  end
end