namespace :data do
  desc 'Find and fix bad appointment date data'
  task fix_bad_appointments: :environment do

    def get_user_input
      puts "Type 'yes' or 'no'"
      answer = STDIN.gets.chomp
      # answer = 'no'

      if answer == "yes"
        #Fix the broken appointment data
        fix_appointments
      elsif answer == "no"
        #End program
        puts "Operation aborted."
      else
        #Wrong input, retry
        puts "Incorrect option."
        get_user_input
      end
    end

    def fix_appointments
      @bad_appointments.each do |appointment|
        #Get completed_date of first procedure completed, and assign it as the start date on the appointment
        new_date = appointment.procedures.where.not(completed_date: nil).order(:completed_date).first.completed_date
        appointment.update_attributes(start_date: new_date)
        puts "Appointment #{appointment.id} assigned to #{appointment.start_date.strftime('%D')}"
      end
    end

    puts "These appointments are not started, but have completed procedures"

    #Grabbing appointments that have no start date, but have completed procedures ("bad" appointments)
    @bad_appointments = Procedure.belonging_to_unbegun_appt.to_a.keep_if{|proc| proc.completed_date != nil}.map(&:appointment).uniq
    @bad_appointments.each do |appointment|
      puts "Appointment ID: #{appointment.id} | Sparc ID: #{appointment.sparc_id} | Appointment Name: #{appointment.name}"
    end

    puts "Would you like to fix these appointments? (assign start date for appointment based on first completed procedure date)"
    get_user_input
  end
end
