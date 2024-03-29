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

class ProcedureCreator

  def initialize(appointment)
    @appointment = appointment
  end

  def initialize_procedures
    unless @appointment.is_a? CustomAppointment # custom appointments don't inherit from the study schedule so there is nothing to build out
      ActiveRecord::Base.transaction do
        @appointment.visit_group.arm.line_items.each do |li|
          visit = li.visits.where("visit_group_id = #{@appointment.visit_group.id}").first
          protocol = @appointment.protocol
          if visit and visit.has_billing?
            attributes = {
              appointment_id: @appointment.id,
              visit_id: visit.id,
              service_name: li.service.name,
              service_id: li.service.id,
              sparc_core_id: li.service.sparc_core_id,
              sparc_core_name: li.service.sparc_core_name
            }
            visit.research_billing_qty.times do
              procedure = Procedure.new(attributes)
              procedure.billing_type = 'research_billing_qty'
              procedure.save
            end
            visit.insurance_billing_qty.times do
              procedure = Procedure.new(attributes)
              procedure.billing_type = 'insurance_billing_qty'
              procedure.save
            end
          end
        end
      end
    end
  end
end