# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

class Visit < ApplicationRecord

  self.per_page = 8

  has_paper_trail
  acts_as_paranoid

  belongs_to :line_item
  belongs_to :visit_group

  has_many :procedures

  delegate :position, to: :visit_group
  validates_numericality_of :research_billing_qty, :insurance_billing_qty, :effort_billing_qty, greater_than_or_equal_to: 0

  def destroy
    procedures.untouched.belonging_to_unbegun_appt.map(&:destroy)

    super
  end

  def has_billing?
    research_billing_qty > 0 ||
      insurance_billing_qty > 0 ||
        effort_billing_qty > 0
  end

  def total_quantity
    research_billing_qty + insurance_billing_qty
  end

  def update_procedures updated_qty, selected_qty_type
    service = self.line_item.service
    new_procedure_values  = []
    new_procedure_columns = [:visit_id, :service_id, :service_name, :billing_type, :sparc_core_id, :sparc_core_name, :appointment_id]
    self.visit_group.arm.protocols_participants.each do |protocols_participant|
      appointment = protocols_participant.appointments.where("visit_group_id = ?", self.visit_group.id).first
      next if (appointment.nil? || appointment.completed_date?)
      
      unless appointment.procedures.empty?
        procedures_available = self.procedures.where("billing_type = ? AND service_id = ? AND appointment_id = ?", selected_qty_type, service.id, appointment.id)
        current_qty = procedures_available.count
        if current_qty > updated_qty and appointment.start_date.nil?    # don't delete procedures from begun appointments
          procedures_to_delete = procedures_available.untouched.limit(current_qty - updated_qty)
          if not procedures_to_delete.empty?
            procedures_to_delete.destroy_all
          end
        elsif current_qty < updated_qty
          (updated_qty - current_qty).times do
            new_procedure_values << [self.id, service.id, service.name, selected_qty_type, service.sparc_core_id, service.sparc_core_name, appointment.id]
          end
        end
      end
    end
    Procedure.import new_procedure_columns, new_procedure_values, {validate: true}
  end
end
