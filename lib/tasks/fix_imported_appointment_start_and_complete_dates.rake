namespace :data do
  desc 'Fix imported appointments which have completed procedures but themselves do not have start/complete dates'
  task fix_imported_appointment_dates: :environment do
    appointments = Appointment.unstarted.with_completed_procedures

    bar = ProgressBar.new(appointments.count)
    
    appointments.each do |appointment|
      bar.increment! rescue nil
      procedure = appointment.procedures.order("completed_date DESC").first # set start and complete to earliest procedure date
      appointment.update_attributes(start_date: procedure.completed_date, completed_date: procedure.completed_date)
    end
  end
end
