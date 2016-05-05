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
    content_tag(:option, "Add as last", value: Appointment.where(arm_id: appointment.arm_id, participant_id: appointment.participant_id).size + 1)
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
                  button_class: "#{procedure.appt_started? ? '' : 'disabled'}"})
  end

  def procedure_service_name_display(service)
    content_tag(:span, service.name) + (service.is_available ? "" : content_tag(:span, " (Inactive)", class: 'inactive-service'))
  end
end
