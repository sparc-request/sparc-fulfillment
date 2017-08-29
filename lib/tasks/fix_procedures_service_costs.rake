# Copyright © 2011-2017 MUSC Foundation for Research Development~
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
  desc "Fix procedures and fulfillments with bad service_cost values"
  task fix_procedure_and_fulfillment_service_costs: :environment do
    CSV.open("tmp/fixed_procedure_and_fulfillment_service_costs.csv", "wb+") do |csv|
      puts 'Are you correcting procedures/fulfillments based on protocol id?, or service id? Please enter "service" or "protocol"'
      type = STDIN.gets.chomp
      if type == "protocol"
        puts 'Please enter a list of protocol IDs, separated by comma, for example: 5 or 5, 4, 3'
        items = Protocol.where(id: STDIN.gets.chomp.split(",").map(&:to_i))
      elsif type == "service"
        puts 'Please enter a list of service IDs, separated by comma, for example: 5, or 3, 4, 5'
        items = Service.where(id: STDIN.gets.chomp.split(",").map(&:to_i))
      end
      puts "Please enter a start date, dd/mm/yyyy :"
      start_date = (STDIN.gets.chomp).to_date
      puts "Please enter an end date, dd/mm/yyyy :"
      end_date = (STDIN.gets.chomp).to_date


      ##Procedures Section
      csv << ["Per Patient Per Visit (Procedures)"]
      csv << ["Protocol ID:", "Procedure ID:", "Service Name", "Previous Price", "Updated Price", "Patient Name:", "Patient ID (MRN)", "Visit Name:", "Visit Date:", "Service Completion Date:", ]
      puts "Fixing Procedures..."

      items.each do |item|
        if item.procedures.count >= 1
          bar = ProgressBar.new(item.procedures.count)
          proc = nil
          item.procedures.find_each do |procedure|
            protocol = procedure.protocol
            service = procedure.service
            #Skip over procedures that don't match time frame
            if !procedure.completed_date.nil? && !(start_date..end_date).cover?(procedure.completed_date.to_date)
              bar.increment! rescue nil
              next
            end

            begin
              proc = procedure
              current_amount = procedure.service_cost
              calculated_amount = 0

              if procedure.complete?
                if procedure.visit
                  calculated_amount = procedure.visit.line_item.cost(protocol.sparc_funding_source, procedure.completed_date)
                else
                  calculated_amount = service.cost(protocol.sparc_funding_source, procedure.completed_date)
                end

                if calculated_amount != current_amount
                  csv << [protocol.sparc_id, procedure.id, procedure.service_name, current_amount, calculated_amount, procedure.participant.try(:full_name), procedure.participant.try(:mrn), procedure.appointment.try(:name), procedure.appointment.try(:start_date).try(:strftime, "%D"), procedure.completed_date.strftime("%D")]
                  procedure.update_attribute(:service_cost, calculated_amount)
                end
              else
                ##Procedure has service cost, but isn't complete, this should never happen, the service_cost needs deleted.
                csv << [protocol.sparc_id, procedure.id, procedure.service_name, "N/A (Erased)", "N/A (Erased)", procedure.participant.try(:full_name), procedure.participant.try(:mrn), procedure.appointment.try(:name), "N/A", "N/A"]
                procedure.update_attribute(:service_cost, nil)
              end

              bar.increment! rescue nil
            rescue Exception => e
              puts "Error with #{proc.inspect}, Message: #{e.message}"
              next
            end
          end
        end
      end

      ##One Time Fees Section
      csv << []
      csv << []
      csv << ["One Time Fee (Fulfillments)"]
      csv << ["Protocol ID:", "fulfillment ID:", "Service Name", "Previous Price", "Updated Price", "Service Completion Date:", ]
      puts "Fixing One Time Fee Fulfillments..."

      if items.map(&:fulfillments).flatten.count >= 1
        bar2 = ProgressBar.new(items.map(&:fulfillments).flatten.count)
        fulf = nil
        items.each do |item|
          item.fulfillments.find_each do |fulfillment|
            protocol = fulfillment.protocol

            #Skip over fulfillments which don't match the time frame
            if !fulfillment.fulfilled_at.nil? && !(start_date..end_date).cover?(fulfillment.fulfilled_at.to_date)
              bar2.increment! rescue nil
              next
            end

            begin
              fulf = fulfillment
              current_amount = fulfillment.service_cost
              calculated_amount = fulfillment.line_item.cost(protocol.sparc_funding_source, fulfillment.fulfilled_at)

              if calculated_amount != current_amount
                csv << [protocol.sparc_id, fulfillment.id, fulfillment.service_name, current_amount, calculated_amount, fulfillment.fulfilled_at.strftime("%D")]
                fulfillment.update_attribute(:service_cost, calculated_amount)
              end

              bar2.increment! rescue nil
            rescue Exception => e
              puts "Error with #{fulf.inspect}, Message: #{e.message}"
              next
            end
          end
        end
      end
    end
  end
end
