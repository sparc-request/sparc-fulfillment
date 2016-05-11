#namespace :data do
#  desc "Fix procedures with bad service_cost values"
#  task fix_procedure_service_cost: :environment do
#    bar = ProgressBar.new(Procedure.complete.count)
#
#    CSV.open("tmp/fixed_procedure_service_costs.csv", "wb+") do |csv|
#      proc = nil
#      Procedure.complete.find_each do |procedure|
#        begin
#          proc = procedure
#          current_amount = procedure.service_cost
#          calculated_amount = 0
#
#          funding_source = procedure.protocol.funding_source
#          visit = procedure.visit
#          service = procedure.service
#          date = procedure.completed_date
#
#          if visit
#            calculated_amount = visit.line_item.cost(funding_source, date)
#          else
#            calculated_amount = service.cost(funding_source, date)
#          end
#
#          if calculated_amount != current_amount
#            csv << ["Protocol ID: #{procedure.protocol.sparc_id}", "Service Name: #{procedure.service_name}","Updating cost for procedure #{procedure.id} from #{current_amount} to #{calculated_amount}"]
#            procedure.update_attribute(:service_cost, calculated_amount)
#          end
#
#          bar.increment! rescue nil
#        rescue Exception => e
#          puts "Error with #{proc.inspect}, Message: #{e.message}"
#          next
#        end
#      end
#    end
#  end
#end

namespace :data do
  desc "Fix procedures and fulfillments with bad service_cost values"
  task fix_procedure_and_fulfillment_service_costs: :environment do
    CSV.open("tmp/fixed_procedure_and_fulfillment_service_costs.csv", "wb+") do |csv|
      puts 'Please enter a list of protocol IDs, separated by comma, for example: 5 or 5, 4, 3'
      protocol_ids = STDIN.gets.chomp.split(",").map(&:to_i)
      puts "Please enter a start date, dd/mm/yyyy :"
      start_date = (STDIN.gets.chomp).to_date
      puts "Please enter an end date, dd/mm/yyyy :"
      end_date = (STDIN.gets.chomp).to_date
      protocols = Protocol.find(protocol_ids)


      ##Procedures Section
      csv << ["Per Patient Per Visit (Procedures)"]
      csv << ["Protocol ID:", "Procedure ID:", "Service Name", "Previous Price", "Updated Price", "Patient Name:", "Patient ID (MRN)", "Visit Name:", "Visit Date:", "Service Completion Date:", ]
      puts "Fixing Procedures..."
      bar = ProgressBar.new(protocols.map(&:procedures).flatten.count)
      proc = nil
      protocols.each do |protocol|
        protocol.procedures.find_each do |procedure|
          # skip over procedures which don't have a service_cost
          if procedure.service_cost.blank? or (!procedure.handled_date.nil? && !(start_date..end_date).cover?(procedure.handled_date.to_date))
            bar.increment! rescue nil
            next
          end

          begin
            proc = procedure
            current_amount = procedure.service_cost
            calculated_amount = 0
            funding_source = protocol.sparc_funding_source
            visit = procedure.visit
            service = procedure.service

            if procedure.complete?
              if visit
                calculated_amount = visit.line_item.cost(funding_source, procedure.completed_date)
              else
                calculated_amount = service.cost(funding_source, procedure.completed_date)
              end

              if calculated_amount != current_amount
                csv << [protocol.sparc_id, procedure.id, procedure.service_name, current_amount, calculated_amount, procedure.participant.full_name, procedure.participant.mrn, procedure.appointment.name, procedure.appointment.start_date.strftime("%D"), procedure.completed_date.strftime("%D")]
                procedure.update_attribute(:service_cost, calculated_amount)
              end
            else
              #procedure has service cost, but isn't complete, this should never happen, and needs deleted.
              csv << [protocol.sparc_id, procedure.id, procedure.service_name, "Incomplete", "Incomplete", procedure.participant.full_name, procedure.participant.mrn, procedure.appointment.name, "N/A", "N/A"]
              procedure.update_attribute(:service_cost, nil)
            end



            bar.increment! rescue nil
          rescue Exception => e
            puts "Error with #{proc.inspect}, Message: #{e.message}"
            next
          end
        end
      end

      ##One Time Fees Section
      csv << []
      csv << []
      csv << ["One Time Fee (Fulfillments)"]
      csv << ["Protocol ID:", "fulfillment ID:", "Service Name", "Previous Price", "Updated Price", "Service Completion Date:", ]
      puts "Fixing One Time Fee Fulfillments..."
      bar2 = ProgressBar.new(protocols.map(&:fulfillments).flatten.count)
      fulf = nil
      protocols.each do |protocol|
        protocol.fulfillments.find_each do |fulfillment|
          if fulfillment.service_cost.blank? or (!fulfillment.fulfilled_at.nil? && !(start_date..end_date).cover?(fulfillment.fulfilled_at.to_date))
            bar2.increment! rescue nil
            next
          end

          begin
            fulf = fulfillment
            current_amount = fulfillment.service_cost
            funding_source = protocol.sparc_funding_source
            calculated_amount = fulfillment.line_item.cost(funding_source, fulfillment.fulfilled_at)

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
