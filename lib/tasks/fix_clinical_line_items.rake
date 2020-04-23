desc "Fix Clinical Line Items"
task fix_clinical_line_items: :environment do

  line_items = LineItem.joins(:service).where(sparc_id: nil, services: {one_time_fee: false})

  puts line_items.count

  CSV.open("tmp/fix_clinical_line_items_#{Time.now.strftime('%m%d%Y%H%M%S')}.csv", "wb") do |csv|

    csv << ["Line Item ID (in Fulfillment)", "Service ID", "Service Name", "Protocol ID (in SPARCRequest)", "Protocol ID (in Fulfillment)", "Sub Service Request ID", "Message"]
    update_count = 0
    line_items.each do |fulfillment_line_item|
      begin
        service_id = fulfillment_line_item.service_id
        sub_service_request = Sparc::SubServiceRequest.find(fulfillment_line_item.protocol.sub_service_request_id)
        request_line_item = sub_service_request.line_items.where(service_id: service_id).first
        fulfillment_line_item_with_sparc_id = request_line_item ? fulfillment_line_item.protocol.line_items.where(sparc_id: request_line_item.id).first : nil

        if fulfillment_line_item_with_sparc_id
          update_count += 1
          puts "Would need to update sparc data"
          csv << [ "#{fulfillment_line_item.id}", "#{service_id}", "#{fulfillment_line_item.service.name}", "#{fulfillment_line_item.protocol.sparc_id}", "#{fulfillment_line_item.protocol.id}", "#{sub_service_request.id}", "A new SPARC Line Item and its related calendar data would need to be created here." ]
        else
          puts "Just need to update the sparc id."
          csv << [ "#{fulfillment_line_item.id}", "#{service_id}", "#{fulfillment_line_item.service.name}", "#{fulfillment_line_item.protocol.sparc_id}", "#{fulfillment_line_item.protocol.id}", "#{sub_service_request.id}", "This line item exists on both sides and just the sparc id would need to be updated." ]
        end

      rescue Exception => e
        puts "Error with Line Item ID: #{fulfillment_line_item.id}, Message: #{e.message}"
        next
      end
    end
    puts "The number of line items that need to be updated in sparc is #{update_count}"
  end
end