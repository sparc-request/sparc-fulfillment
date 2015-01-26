module ParticipantHelper

  def appointments_for_select arm, participant
    appointments = []
    participant.appointments.each do |appt|
      if appt.visit_group.arm.name == arm.name
        appointments << appt
      end
    end

    appointments
  end

  def arms_for_appointments appts
    arms = appts.map{|x| x.visit_group.arm}

    arms.uniq
  end
end