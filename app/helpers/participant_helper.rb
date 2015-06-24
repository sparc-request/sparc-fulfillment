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
    appts.map{|x| x.arm}.uniq
  end

  def us_states
    ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'District of Columbia', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Puerto Rico', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming', 'N/A']
  end

  def detailsFormatter participant
    [
      "<a class='details participant-details ml10' href='#' title='Details' protocol_id='#{participant.protocol_id}' participant_id='#{participant.id}'>",
      "<i class='glyphicon glyphicon-sunglasses'></i>",
      "</a>"
    ].join ""
  end

  def editFormatter participant
    [
      "<a class='edit edit-participant ml10' href='#' title='Edit' protocol_id='#{participant.protocol_id}' participant_id='#{participant.id}'>",
      "<i class='glyphicon glyphicon-edit'></i>",
      "</a>"
    ].join ""
  end

  def deleteFormatter participant
    [
      "<a class='remove remove-participant' href='#' title='Remove' protocol_id='#{participant.protocol_id}' participant_id='#{participant.id}' participant_name='#{participant.full_name}'>",
      "<i class='glyphicon glyphicon-remove'></i>",
      "</a>"
    ].join ""
  end

  def changeArmFormatter participant
    [
      "<a class='edit change-arm ml10' href='#' title='Change Arm' protocol_id='#{participant.protocol_id}' participant_id='#{participant.id}' arm_id='#{participant.arm_id}'>",
      "<i class='glyphicon glyphicon-random'></i>",
      "</a>"
    ].join ""
  end

  def calendarFormatter participant
    [
      "<a class='participant-calendar' href='#' title='Calendar' protocol_id='#{participant.protocol_id}' participant_id='#{participant.id}'>",
      "<i class='glyphicon glyphicon-calendar'></i>",
      "</a>"
    ].join ""
  end

  def participant_report_formatter(participant)
    content_tag(:a, class: 'btn btn-default btn-xs participant_report', href: '#', title: 'Participant Report', 'data-documentable_type' => 'Protocol', 'data-documentable_id' => participant.protocol.id, 'data-participant_id' => participant.id, 'data-title' => 'participant_report') do
      content_tag(:span, '', class: 'glyphicon glyphicon-equalizer')
    end
  end
end
