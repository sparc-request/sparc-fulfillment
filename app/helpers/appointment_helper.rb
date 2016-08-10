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
                  button_class: "#{procedure.appt_started? ? '' : 'disabled'}"})
  end
end
