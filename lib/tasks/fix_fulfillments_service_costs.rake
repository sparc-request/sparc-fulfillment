namespace :data do
  desc "Fix fulfillments with bad service_cost values"
  task fix_fulfillments_service_cost: :environment do
    bar = ProgressBar.new(Fulfillment.count)

    CSV.open("tmp/fixed_fulfillments_service_costs.csv", "wb+") do |csv|
      proc = nil
      Fulfillment.find_each do |fulfillment|
        begin
          proc = fulfillment
          current_amount = fulfillment.service_cost
          calculated_amount = 0

          funding_source = fulfillment.line_item.protocol.sparc_funding_source
          service = fulfillment.service
          date = fulfillment.fulfilled_at

          calculated_amount = service.cost(funding_source, date)

          if calculated_amount != current_amount
            csv << ["Protocol ID: #{fulfillment.line_item.protocol.sparc_id}", "Service Name: #{fulfillment.service_name}","Updating cost for fulfillment #{fulfillment.id} from #{current_amount} to #{calculated_amount}"]
            fulfillment.update_attribute(:service_cost, calculated_amount)
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
