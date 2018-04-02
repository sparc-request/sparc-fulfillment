class FixFulfillmentsFromEditedLineItems < ActiveRecord::Migration[5.0]
  def change
    #Find Line Items that have a name, and no fulfillments (bad data), and correct.
    LineItem.left_outer_joins(:fulfillments).where(fulfillments: { id: nil} ).where.not(name: nil).each do |line_item|
      #Double check is OTF, just in case (shouldn't ever happen)
      if line_item.service.one_time_fee
        #Remove name (this is now done automatically going forward)
        line_item.update_attributes(name: nil)
      end
    end

    #Find Fulfillments that have a service_id that doesn't match their line_item's service_id, and correct.
    Fulfillment.includes(:line_item).find_each do |fulfillment|
      begin
        if fulfillment.service_id != fulfillment.line_item.service_id
          line_item = fulfillment.line_item

          #Correct fulfillment service name, service id, and service cost
          fulfillment.service_id = line_item.service_id
          fulfillment.service_name = line_item.service.name
          fulfillment.service_cost = line_item.cost(line_item.protocol.sparc_funding_source, fulfillment.fulfilled_at)
          fulfillment.save(validate: false)

          #Fix line item service name
          line_item.name = line_item.service.name
          line_item.save(validate: false)

          #Destroy components that fit old service
          fulfillment.components.destroy_all

          puts "Fixing Fulfillment: #{fulfillment.id}"
        end
      rescue Exception => e
        puts "#"*20
        puts e.message
        puts "#"*20
      end
    end
  end
end
