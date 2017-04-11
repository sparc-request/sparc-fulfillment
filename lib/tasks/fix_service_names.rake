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
  desc "Fix procedure and fulfillment service names"
  task fix_procedure_and_fulfillment_service_names: :environment do
    CSV.open("tmp/fixed_procedure_and_fulfillment_service_names.csv", "wb+") do |csv|
      puts 'Please enter a list of service IDs, separated by comma, for example: 5, or 3, 4, 5'
      services = Service.find(STDIN.gets.chomp.split(",").map(&:to_i))

      puts "Please enter a start date, dd/mm/yyyy :"
      start_date = (STDIN.gets.chomp).to_date
      puts "Please enter an end date, dd/mm/yyyy :"
      end_date = (STDIN.gets.chomp).to_date


      ##Procedures Section
      csv << ["Per Patient Per Visit (Procedures)"]
      csv << ["Protocol ID:", "Procedure ID:", "Original Service Name", "New Service Name", "Patient Name:", "Patient ID (MRN)", "Visit Name:"]

      services.each do |service|
        ##Change names for completed procedures
        csv << ["Completed Procedures:"]
        puts "Fixing Complete Procedures..."
        complete_bar = ProgressBar.new(service.procedures.where(status: "complete").count)
        service.procedures.where(status: "complete").find_each do |procedure|
          ##Check date range. We only want to update completed procedures if they are in the date range
          if (start_date..end_date).cover?(procedure.completed_date.to_date) && procedure.service_name != service.name
            csv << [procedure.protocol.sparc_id, procedure.id, procedure.service_name, service.name, procedure.participant.try(:full_name), procedure.participant.try(:mrn), procedure.appointment.try(:name)]
            procedure.update_attribute(:service_name, service.name)
            complete_bar.increment!
          else
            complete_bar.increment!
          end
        end

        csv << ["Non Complete Procedures"]
        puts "Fixing non-completed procedures"
        non_complete_bar = ProgressBar.new(service.procedures.where.not(status: "complete").count)
        service.procedures.where.not(status: "complete").find_each do |procedure|
          if procedure.service_name != service.name
            csv << [procedure.protocol.sparc_id, procedure.id, procedure.service_name, service.name, procedure.participant.try(:full_name), procedure.participant.try(:mrn), procedure.appointment.try(:name)]
            procedure.update_attribute(:service_name, service.name)
            non_complete_bar.increment!
          else
            non_complete_bar.increment!
          end
        end
      end

      ##One Time Fees Section
      csv << []
      csv << []
      csv << ["One Time Fee (Fulfillments)"]
      csv << ["Protocol ID:", "fulfillment ID:", "Original Service Name", "New Service Name"]

      csv << ["Finished Fulfillments"]
      puts "Fixing fulfilled fulfillments"
      finished_bar = ProgressBar.new(service.fulfillments.where.not(fulfilled_at: nil).count)
      ##CHeck date range for fulfilled(finished) fulfillments
      service.fulfillments.where.not(fulfilled_at: nil).find_each do |fulfillment|
        if (start_date..end_date_).cover?(fulfillment.fulfilled_at.to_date) && fulfillment.service_name != service.name
          csv << [protocol.sparc_id, fulfillment.id, fulfillment.service_name, service.name]
          fulfillment.update_attribute(:service_name, service.name)
          finished_bar.increment!
        else
          finished_bar.increment!
        end
      end

      csv << ["Un-Finished Fulfillments"]
      puts "Fixing un-finished fulfillments"
      unfinished_bar = ProgressBar.new(service.fulfillments.where(fulfilled_at: nil).count)
      service.fulfillments.where(fulfilled_at: nil).find_each do |fulfillment|
        if fulfillment.service_name != service.name
          csv << [protocol.sparc_id, fulfillment.id, fulfillment.service_name, service.name]
          fulfillment.update_attribute(:service_name, service.name)
          unfinished_bar.increment!
        else
          unfinished_bar.increment!
        end
      end
    end
  end
end
