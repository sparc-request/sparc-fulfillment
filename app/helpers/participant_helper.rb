# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

module ParticipantHelper

  def appointments_for_select(arm, participant)
    appointments = []
    participant.appointments.incompleted.each do |appt|
      if appt.arm.name == arm.name
        appointments << appt
      end
    end

    appointments
  end

  def arms_for_appointments(appts)
    appts.map{|x| x.arm}.compact.uniq
  end

  def us_states
    ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'District of Columbia', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Puerto Rico', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming', 'N/A']
  end

  def detailsFormatter(participant)
    [
      "<a class='details participant-details ml10' href='javascript:void(0)' title='Details' protocol_id='#{participant.protocol_id}' participant_id='#{participant.id}'>",
      "<i class='glyphicon glyphicon-sunglasses'></i>",
      "</a>"
    ].join ""
  end

  def editFormatter(participant)
    [
      "<a class='edit edit-participant ml10' href='javascript:void(0)' title='Edit' protocol_id='#{participant.protocol_id}' participant_id='#{participant.id}'>",
      "<i class='glyphicon glyphicon-edit'></i>",
      "</a>"
    ].join ""
  end

  def deleteFormatter(participant)
    [
      "<a class='remove remove-participant' href='javascript:void(0)' title='Remove' protocol_id='#{participant.protocol_id}' participant_id='#{participant.id}' participant_name='#{participant.full_name}'>",
      "<i class='glyphicon glyphicon-remove'></i>",
      "</a>"
    ].join ""
  end

  def changeArmFormatter(participant)
    [
      "<a class='edit change-arm ml10' href='javascript:void(0)' title='Change Arm' protocol_id='#{participant.protocol_id}' participant_id='#{participant.id}' arm_id='#{participant.arm_id}'>",
      "<i class='glyphicon glyphicon-random'></i>",
      "</a>"
    ].join ""
  end

  def calendarFormatter(participant)
    if participant.appointments.empty?
      "<i class='glyphicon glyphicon-calendar' title='Assign arm to view participant calendar' style='cursor:default'></i>"
    else
      [
        "<a class='participant-calendar' href='javascript:void(0)' title='Calendar' protocol_id='#{participant.protocol_id}' participant_id='#{participant.id}'>",
        "<i class='glyphicon glyphicon-calendar'></i>",
        "</a>"
      ].join ""
    end
  end

  def phoneNumberFormatter(participant)
    if participant.phone.length == 10
      "#{participant.phone[0..2]}-#{participant.phone[3..5]}-#{participant.phone[6..10]}"
    else
      participant.phone
    end
  end

  def statusFormatter(participant)
    select_tag "participant_status_#{participant.id}", options_for_select(Participant::STATUS_OPTIONS, participant.status), include_blank: true, class: "participant_status selectpicker form-control #{dom_id(participant)}", data:{container: "body", id: participant.id}
  end

  def notes_formatter(participant)
    notes_button({object: participant,
                  title: t(:participant)[:notes],
                  has_notes: participant.notes.any?,
                  button_class: 'participant_notes'})
  end

  def participant_report_formatter(participant)
    protocol  = participant.protocol
    icon_span = raw content_tag(:span, '', class: "glyphicon glyphicon-equalizer")
    button    = raw content_tag(:button, raw(icon_span), type: 'button', class: 'btn btn-default btn-xs report-button participant_report dropdown-toggle', id: "participant_report_#{participant.id.to_s}", 'aria-expanded' => 'false', title: 'Participant Report', 'data-title' => 'Participant Report', 'data-report_type' => 'participant_report',  'data-documentable_id' => protocol.id, 'data-documentable_type' => 'Protocol', 'data-participant_id' => participant.id)
    ul        = raw content_tag(:ul, '', class: 'document-dropdown-menu hidden', id: "document_menu_participant_report_#{participant.id.to_s}", role: 'menu')
    html      = raw content_tag(:div, button + ul, class: 'btn-group')
  end
end
