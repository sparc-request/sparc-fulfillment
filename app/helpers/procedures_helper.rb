# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

module ProceduresHelper
  def procedure_billing_display(procedure)
    disabled = procedure.invoiced? || !procedure.appointment.started?
    tooltip =
      if procedure.invoiced?
        t('procedures.tooltips.invoiced_warning')
      elsif !procedure.appointment.started?
        t('procedures.tooltips.unstarted_appointment')
      end

    form_for procedure, url: appointment_procedure_path(procedure, appointment_id: procedure.appointment_id), remote: true, method: :put do |f|
      content_tag :div, class: 'tooltip-wrapper', title: tooltip, data: { toggle: disabled ? 'tooltip' : '' } do
        hidden_field_tag(:field, 'billing_type') +
        f.select(:billing_type, options_for_select(Procedure.billing_display, procedure.billing_type), {}, onchange: "Rails.fire(this.form, 'submit')", class: 'selectpicker', disabled: disabled)
      end
    end
  end

  def procedure_performer_display(procedure)
    disabled = procedure.invoiced? || !procedure.appointment.started?
    tooltip =
      if procedure.invoiced?
        t('procedures.tooltips.invoiced_warning')
      elsif !procedure.appointment.started?
        t('procedures.tooltips.unstarted_appointment')
      end

    form_for procedure, url: appointment_procedure_path(procedure, appointment_id: procedure.appointment_id), remote: true, method: :put do |f|
      content_tag :div, class: 'tooltip-wrapper', title: tooltip, data: { toggle: disabled ? 'tooltip' : '' } do
        f.select :performer_id, options_from_collection_for_select(procedure.performable_by, :id, :full_name, procedure.performer_id), { include_blank: true }, onchange: "Rails.fire(this.form, 'submit')", class: 'selectpicker', disabled: disabled
      end
    end
  end
end
