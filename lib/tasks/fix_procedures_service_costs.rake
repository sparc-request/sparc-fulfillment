namespace :data do
  desc "Fix procedures with bad service_cost values"
  task fix_procedure_service_cost: :environment do
    bar = ProgressBar.new(Procedure.complete.count)

    CSV.open("/tmp/fixed_procedure_service_costs.csv", "wb+") do |csv|
      begin
        proc = nil
        Procedure.complete.each do |procedure|
          proc = procedure
          current_amount = procedure.service_cost
          calculated_amount = 0

          funding_source = procedure.protocol.funding_source
          visit = procedure.visit
          service = procedure.service
          date = procedure.completed_date

          if visit
            calculated_amount = visit.line_item.cost(funding_source, date)
          else
            calculated_amount = service.cost(funding_source, date)
          end

          if calculated_amount != current_amount
            csv << ["Updating cost for procedure #{procedure.id} from #{current_amount} to #{calculated_amount}"]
            procedure.update_attribute(:service_cost, calculated_amount)
          end

          bar.increment! rescue nil
        end
      rescue Exception => e
        puts "Error with #{proc.inspect}, Message: #{e.message}"
      end
    end
  end
end

