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

  def historical_statuses statuses
    old_statuses = []
    statuses.each do |status|
      unless Appointment::STATUSES.include? status
        old_statuses << status
      end
    end

    old_statuses
  end

  def app_add_as_last_option(appointment)
    content_tag(:option, "Add as last", value: '')
  end

  def appointment_notes_formatter(appointment)
    notes_button({object: appointment,
                  title: t(:appointment)[:notes],
                  has_notes: appointment.notes.any?})
  end

  def procedure_notes_formatter(procedure)
    notes_button({object: procedure,
                  title: t(:participant)[:notes],
                  has_notes: procedure.notes.any?,
                  button_class: "#{procedure.appt_started? ? '' : 'disabled pre_start_disabled'}"})
  end

  def procedures_invoiced_or_credited?(appointment)
    appointment.procedures.any?{ |procedure| procedure.invoiced == true || procedure.credited == true }
  end

  def procedures_invoiced?(appointment)
    appointment.procedures.any?{ |procedure| procedure.invoiced == true }
  end

  def procedures_credited?(appointment)
    appointment.procedures.any?{ |procedure| procedure.credited == true }
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
