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
