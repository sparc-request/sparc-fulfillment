# Copyright © 2011-2023 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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