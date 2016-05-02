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
  desc "Fix procedures with bad service_cost values"
  task fix_procedure_service_cost: :environment do
    puts "Please enter a protocol (CWF internal id)"
    protocol_id = STDIN.gets.chomp
    protocol = Protocol.find(protocol_id)
    bar = ProgressBar.new(protocol.procedures.count)

    CSV.open("tmp/fixed_procedure_service_costs.csv", "wb+") do |csv|
      proc = nil
      protocol.procedures.find_each do |procedure|
        # skip over procedures which don't have a service_cost
        next if procedure.service_cost.blank?

        begin
          proc = procedure
          current_amount = procedure.service_cost
          calculated_amount = 0

          funding_source = procedure.protocol.sparc_funding_source
          visit = procedure.visit
          service = procedure.service

          if procedure.complete?
            if visit
              calculated_amount = visit.line_item.cost(funding_source, procedure.completed_date)
            else
              calculated_amount = service.cost(funding_source, procedure.completed_date)
            end

            if calculated_amount != current_amount
              csv << ["Protocol ID: #{procedure.protocol.sparc_id}", "Service Name: #{procedure.service_name}","Updating cost for procedure #{procedure.id} from #{current_amount} to #{calculated_amount}"]
              procedure.update_attribute(:service_cost, calculated_amount)
            end
          else
            #procedure has service cost, but isn't complete, this should never happen, and needs deleted.
            csv << ["Protocol ID: #{procedure.protocol.sparc_id}", "Service Name: #{procedure.service_name}","Deleting cost for non-complete procedure"]
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
end
