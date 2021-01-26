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

module AppointmentHelper
  def appointment_context_icon(appointment)
    if appointment.completed?
      icon('fas', 'check fa-lg text-success', title: t('appointments.tooltips.state.completed'), data: { toggle: 'tooltip' })
    elsif appointment.started?
      icon('far', 'clock fa-lg text-warning', title: t('appointments.tooltips.state.started', date: format_date(appointment.start_date)), data: { toggle: 'tooltip' })
    else
      icon('fas', 'times fa-lg text-secondary', title: t('appointments.tooltips.state.unstarted', date: format_date(appointment.completed_date)), data: { toggle: 'tooltip' })
    end
  end

  def start_appointment_button(appointment)
    content_tag :button, t('appointments.start_visit'), class: 'btn btn-primary start-appointment mr-1', data: { url: appointment_path(appointment) }
  end

  def reset_appointment_button(appointment)
    tooltip =
      if appointment.has_invoiced_procedures? && appointment.has_credited_procedures?
        t('appointment.tooltips.reset_visit.disabled_credited_and_invoiced')
      elsif appointment.has_invoiced_procedures?
        t('appointment.tooltips.reset_visit.disabled_invoiced')
      elsif appointment.has_credited_procedures?
        t('appointment.tooltips.reset_visit.disabled_credited')
      end

    content_tag :div, class: 'tooltip-wrapper mx-1', title: tooltip, data: { toggle: 'tooltip' } do
      link_to reset_procedures_appointment_multiple_procedures_path(appointment_id: appointment.id), remote: true, method: :put, class: ['btn btn-warning reset-appointment', appointment.has_invoiced_procedures? || appointment.has_credited_procedures? ? 'disabled' : ''], data: { confirm_swal: 'true', html: t('appointments.confirms.reset_visit.text') } do
        icon('fas', 'sync mr-1') + t('appointments.reset_visit')
      end
    end
  end

  def complete_appointment_buttons(appointment)
    content_tag :div, class: 'tooltip-wrapper', title: appointment.can_finish? ? '' : t('appointments.tooltips.complete_visit.disabled'), data: { toggle: 'tooltip' } do
      content_tag :button, class: ['btn btn-success complete-appointment', appointment.can_finish? ? '' : 'disabled'], data: { url: appointment_path(appointment), confirm_swal: true } do
        icon('fas', 'check mr-1') + t('appointments.complete_visit')
      end
    end
  end

  def app_add_as_last_option(appointment)
    content_tag(:option, "Add as last", value: '')
  end

  def procedure_notes_formatter(procedure)
    notes_button(procedure, title: t(:participant)[:notes], button_class: "#{procedure.appt_started? ? '' : 'disabled pre_start_disabled'}")
  end

  def position_options_button(procedure)
    options = raw(
      move_to_top_list_item(procedure)+
      move_up_list_item(procedure)+
      move_down_list_item(procedure)+
      move_to_bottom_list_item(procedure)
    )
    span = raw(content_tag(:span, '', class: "glyphicon glyphicon-move", aria: {hidden: "true"}))

    button = raw(content_tag(:button, raw(span), type: "button", class: "btn btn-primary move_procedure_button", 'data-toggle' => 'dropdown', 'aria-expanded' => 'false'))
    ul = raw content_tag(:ul, options, class: 'dropdown-menu', role: 'menu')

    raw(content_tag(:div, button + ul, class: 'btn-group'))
  end

  private

  def move_to_top_list_item(procedure)
    content_tag(:li, raw(
      content_tag(:button,
        raw(content_tag(:span, '', id: "procedure_#{procedure.id}_move_down", class: "glyphicon glyphicon-upload", aria: {hidden: "true"})) +
        " Move to top",
        type: 'button', class: "btn btn-default form-control actions-button list procedure_move_button", data: {procedure_id: procedure.id, movement_type: "to_top"}))
    )
  end

  def move_up_list_item(procedure)
    content_tag(:li, raw(
      content_tag(:button,
        raw(content_tag(:span, '', id: "procedure_#{procedure.id}_move_up", class: "glyphicon glyphicon-arrow-up", aria: {hidden: "true"})) +
        " Move Up",
        type: 'button', class: "btn btn-default form-control actions-button list procedure_move_button", data: {procedure_id: procedure.id, movement_type: "higher"}))
    )
  end

  def move_down_list_item(procedure)
    content_tag(:li, raw(
      content_tag(:button,
        raw(content_tag(:span, '', id: "procedure_#{procedure.id}_move_down", class: "glyphicon glyphicon-arrow-down", aria: {hidden: "true"})) +
        " Move Down",
        type: 'button', class: "btn btn-default form-control actions-button list procedure_move_button", data: {procedure_id: procedure.id, movement_type: "lower"}))
    )
  end

  def move_to_bottom_list_item(procedure)
    content_tag(:li, raw(
      content_tag(:button,
        raw(content_tag(:span, '', id: "procedure_#{procedure.id}_move_down", class: "glyphicon glyphicon-download", aria: {hidden: "true"})) +
        " Move to bottom",
        type: 'button', class: "btn btn-default form-control actions-button list procedure_move_button", data: {procedure_id: procedure.id, movement_type: "to_bottom"}))
    )
  end

end
