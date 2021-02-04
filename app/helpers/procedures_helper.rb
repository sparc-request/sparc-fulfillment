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
    disabled = !procedure.appointment.started? || procedure.invoiced?
    tooltip =
      if !procedure.appointment.started?
        t('procedures.tooltips.unstarted_appointment')
      elsif procedure.invoiced?
        t('procedures.tooltips.invoiced.disabled')
      end

    form_for procedure, url: appointment_procedure_path(procedure, appointment_id: procedure.appointment_id), remote: true, method: :put do |f|
      content_tag :div, class: 'tooltip-wrapper', title: tooltip, data: { toggle: disabled ? 'tooltip' : '' } do
        hidden_field_tag(:field, 'billing_type') +
        f.select(:billing_type, options_for_select(Procedure.billing_display, procedure.billing_type), {}, onchange: "Rails.fire(this.form, 'submit')", class: 'selectpicker', disabled: disabled)
      end
    end
  end

  def procedure_performer_display(procedure, performable_by)
    disabled = !procedure.appointment.started? || procedure.invoiced?
    tooltip =
      if !procedure.appointment.started?
        t('procedures.tooltips.unstarted_appointment')
      elsif procedure.invoiced?
        t('procedures.tooltips.invoiced.disabled')
      end

    form_for procedure, url: appointment_procedure_path(procedure, appointment_id: procedure.appointment_id), remote: true, method: :put do |f|
      content_tag :div, class: 'tooltip-wrapper', title: tooltip, data: { toggle: disabled ? 'tooltip' : '' } do
        f.select :performer_id, options_from_collection_for_select(performable_by, :id, :full_name, procedure.performer_id), { include_blank: true }, onchange: "Rails.fire(this.form, 'submit')", class: 'selectpicker', disabled: disabled, data: { width: '125' }
      end
    end
  end

  def procedure_invoiced_display(procedure)
    disabled = !procedure.complete? || procedure.invoiced? || procedure.credited?
    tooltip =
      if !procedure.appointment.started?
        t('procedures.tooltips.unstarted_appointment')
      elsif !procedure.complete?
        t('procedures.tooltips.invoiced.incomplete_procedure')
      elsif procedure.invoiced?
        t('procedures.tooltips.invoiced.disabled')
      elsif procedure.credited?
        t('procedures.tooltips.credited.disabled')
      else
        t('procedures.tooltips.invoiced.warning')
      end

    if current_identity.billing_manager_protocols.include?(procedure.protocol)
      form_for procedure, url: appointment_procedure_path(procedure, appointment_id: procedure.appointment_id), remote: true, method: :put do |f|
        content_tag :div, class: 'tooltip-wrapper', title: tooltip, data: { toggle: 'tooltip' } do
          f.check_box :invoiced, disabled: disabled, onchange: "Rails.fire(this.form, 'submit')", data: { toggle: 'toggle', id: procedure.id, on: t('constants.yes_select'), off: t('constants.no_select') }
        end
      end
    else
      procedure.invoiced? ? t('constants.yes_select') : t('constants.no_select')
    end
  end

  def procedure_credited_display(procedure)
    disabled = !procedure.complete? || procedure.invoiced? || procedure.credited?
    tooltip =
      if !procedure.appointment.started?
        t('procedures.tooltips.unstarted_appointment')
      elsif !procedure.complete?
        t('procedures.tooltips.invoiced.incomplete_procedure')
      elsif procedure.invoiced?
        t('procedures.tooltips.invoiced.disabled')
      elsif procedure.credited?
        t('procedures.tooltips.credited.disabled')
      else
        t('procedures.tooltips.credited.warning')
      end

    if current_identity.billing_manager_protocols_allow_credit.include?(procedure.protocol)
      form_for procedure, url: appointment_procedure_path(procedure, appointment_id: procedure.appointment_id), remote: true, method: :put do |f|
        content_tag :div, class: 'tooltip-wrapper', title: tooltip, data: { toggle: 'tooltip' } do
          f.check_box :credited, disabled: disabled, onchange: "Rails.fire(this.form, 'submit')", data: { toggle: 'toggle', id: procedure.id, on: t('constants.yes_select'), off: t('constants.no_select') }
        end
      end
    else
      procedure.credited? ? t('constants.yes_select') : t('constants.no_select')
    end
  end

  def procedure_notes_display(procedure)
    disabled = !procedure.appointment.started? || procedure.invoiced?
    tooltip =
      if !procedure.appointment.started?
        t('procedures.tooltips.unstarted_appointment')
      elsif procedure.invoiced?
        t('procedures.tooltips.invoiced.disabled')
      end

    notes_button(procedure, disabled: disabled, tooltip: tooltip)
  end

  def procedure_actions(procedure)
    content_tag :div, class: 'd-flex justify-content-center' do
      raw([
        delete_procedure_button(procedure)
      ].join(''))
    end
  end

  def delete_procedure_button(procedure)
    disabled = !procedure.appointment.started? || procedure.invoiced?
    tooltip =
      if !procedure.appointment.started?
        t('procedures.tooltips.unstarted_appointment')
      elsif procedure.invoiced?
        t('procedures.tooltips.invoiced.disabled')
      else
        t('procedures.tooltips.delete')
      end

    content_tag :div, class: 'tooltip-wrapper', title: tooltip, data: { toggle: 'tooltip' } do
      link_to icon('fas', 'trash'), appointment_procedure_path(procedure, appointment_id: procedure.appointment_id), remote: true, method: :delete, class: ['btn btn-danger btn-sq', disabled ? 'disabled' : ''], data: { confirm_swal: 'true' }
    end
  end
end
