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

  def appointment_notes_formatter appointment
    if appointment.notes.any?
      content_tag(:button, class: "btn btn-primary list notes", title: t(:appointment)[:notes], type: "button", label: "Notes List", 'data-notable-id' => appointment.id, 'data-notable-type' => 'Appointment', toggle: "tooltip", animation: 'false') do
        content_tag(:span, '', class: "glyphicon glyphicon-list-alt")
      end
    else
      content_tag(:button, class: "btn btn-default list notes", title: t(:appointment)[:notes], type: "button", label: "Notes List", 'data-notable-id' => appointment.id, 'data-notable-type' => 'Appointment', toggle: "tooltip", animation: 'false') do
        content_tag(:span, '', class: "glyphicon glyphicon-list-alt blue-notes")
      end
    end
  end

  def procedure_notes_formatter procedure
    if procedure.notes.any?
      content_tag(:button, class: "btn btn-primary list notes #{procedure.appt_started? ? '' : 'disabled'}", title: t(:procedure)[:notes], type: "button", label: "Notes List", 'data-notable-id' => procedure.id, 'data-notable-type' => 'Procedure', toggle: "tooltip", animation: 'false') do
        content_tag(:span, '', class: "glyphicon glyphicon-list-alt")
      end
    else
      content_tag(:button, class: "btn btn-default list notes #{procedure.appt_started? ? '' : 'disabled'}", title: t(:procedure)[:notes], type: "button", label: "Notes List", 'data-notable-id' => procedure.id, 'data-notable-type' => 'Procedure', toggle: "tooltip", animation: 'false') do
        content_tag(:span, '', class: "glyphicon glyphicon-list-alt blue-notes")
      end
    end
  end
end
