module ParticipantHelper
  def appointments_for_select arm, participant
    appointments = []
    participant.appointments.each do |appt|
      if appt.arm.name == arm.name
        appointments << appt
      end
    end

    appointments
  end

  def arms_for_appointments appts
    appts.map{|x| x.arm}.compact.uniq
  end

  def us_states
    ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'District of Columbia', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Puerto Rico', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming', 'N/A']
  end

  def detailsFormatter participant
    [
      "<a class='details participant-details ml10' href='javascript:void(0)' title='Details' protocol_id='#{participant.protocol_id}' participant_id='#{participant.id}'>",
      "<i class='glyphicon glyphicon-sunglasses'></i>",
      "</a>"
    ].join ""
  end

  def editFormatter participant
    [
      "<a class='edit edit-participant ml10' href='javascript:void(0)' title='Edit' protocol_id='#{participant.protocol_id}' participant_id='#{participant.id}'>",
      "<i class='glyphicon glyphicon-edit'></i>",
      "</a>"
    ].join ""
  end

  def deleteFormatter participant
    [
      "<a class='remove remove-participant' href='javascript:void(0)' title='Remove' protocol_id='#{participant.protocol_id}' participant_id='#{participant.id}' participant_name='#{participant.full_name}'>",
      "<i class='glyphicon glyphicon-remove'></i>",
      "</a>"
    ].join ""
  end

  def changeArmFormatter participant
    [
      "<a class='edit change-arm ml10' href='javascript:void(0)' title='Change Arm' protocol_id='#{participant.protocol_id}' participant_id='#{participant.id}' arm_id='#{participant.arm_id}'>",
      "<i class='glyphicon glyphicon-random'></i>",
      "</a>"
    ].join ""
  end

  def calendarFormatter participant
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

  def phoneNumberFormatter participant
    if participant.phone.length == 10
      "#{participant.phone[0..2]}-#{participant.phone[3..5]}-#{participant.phone[6..10]}"
    else
      participant.phone
    end
  end

  def statusFormatter participant
    select_tag "participant_status_#{participant.id}", options_for_select(Participant::STATUS_OPTIONS, participant.status), include_blank: true, class: "participant_status selectpicker form-control #{dom_id(participant)}", data:{container: "body", id: participant.id}
  end

  def notes_formatter participant
    content_tag(:button, class: 'btn btn-primary btn-xs participant_notes list notes', 'data-notable-id' => participant.id, 'data-notable-type' => 'Participant') do
      content_tag(:span, '', class: "glyphicon glyphicon-list-alt")
    end
  end

  def participant_report_formatter participant
    content_tag(:div, '', class: 'btn-group') do
      content_tag(:a, class: 'btn btn-default dropdown-toggle btn-xs participant_report', id: "participant_report_#{participant.id.to_s}", href: 'javascript:void(0)', target: :blank, title: 'Participant Report', 'data-documentable_type' => 'Protocol', 'data-documentable_id' => participant.protocol.id, 'data-participant_id' => participant.id, 'data-title' => 'Participant Report', 'data-report_type' => 'participant_report', 'aria-expanded' => 'false') do
        content_tag(:span, '', class: 'glyphicon glyphicon-equalizer')
      end +
      content_tag(:ul, '', class: 'dropdown-menu document-dropdown-menu menu-participant', role: 'menu', id: "document_menu_participant_report_#{participant.id.to_s}")
    end
  end
end
