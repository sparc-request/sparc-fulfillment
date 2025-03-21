require 'csv'

task add_klok_fulfillments_from_csv: :environment do

  successful_rows = []
  failed_rows = []

  puts 'Enter path to csv:'
  file_path = STDIN.gets.strip

  begin
    data = CSV.read(
      file_path,
      headers: true,
      converters: :all,
      header_converters: ->(h) { h.downcase.gsub(' ', '_') }
    ).map(&:to_hash).map(&:symbolize_keys)
  rescue => e
    puts "Error reading CSV file: #{e.message}"
    next
  end

  data.each_with_index do |item, index|
    row_num = index + 2

    begin
      unless item[:sparc_service_request_id].present?
        raise "Missing Sparc Service Request ID"
      end
      unless item[:completed_by].present?
        raise "Missing Completed By information"
      end
      unless item[:date_fulfilled].present?
        raise "Missing Date Fulfilled"
      end
      unless item[:start_time].present? && item[:end_time].present?
        raise "Missing Start Time or End Time"
      end

      # get ssr
      protocol_id, ssr_id = item[:sparc_service_request_id].split('-', 2)
      ssr = SubServiceRequest.find_by(protocol_id: protocol_id.to_i, ssr_id: ssr_id)

      unless ssr
        raise "Can't find SubServiceRequest for: #{item[:sparc_service_request_id]}"
      end

      # get sparc::line_item
      sparc_line_items = Sparc::LineItem.where(sub_service_request: ssr.id)
      sparc_line_items = sparc_line_items.each { |li| li.service.name == item[:service_name] }


      if sparc_line_items.empty?
        raise "Can't find Sparc::LineItem for service: #{item[:service_name]} with SubServiceRequest id: #{ssr.id}"
      end

      sparc_line_item = sparc_line_items.first

      # get cwf line_item
      line_item = LineItem.find_by(sparc_id: sparc_line_item.id)

      unless line_item
        raise "Can't find LineItem with sparc_id: #{sparc_line_item.id}"
      end

      # get completed by identity
      first_name, last_name = item[:completed_by].split(" ", 2)
      performers = Identity.where(first_name: first_name, last_name: last_name)

      if performers.empty?
        raise "No Identity with fn ln: #{item[:completed_by]}"
      end

      performer = performers.first

      # get fulfillment date and time
      begin
        fulfillment_date = DateTime.strptime(item[:date_fulfilled], '%m/%d/%y')
      rescue
        raise "Invalid date format: #{item[:date_fulfilled]}"
      end

      begin
        fulfillment_time = Time.strptime(item[:end_time], '%I:%M %p') - Time.strptime(item[:start_time], '%I:%M %p')
      rescue
        raise "Invalid time format: #{item[:start_time]} or #{item[:end_time]}"
      end

      # Build fulfillment
      funding_source = line_item.protocol.sparc_funding_source

      fulfillment = line_item.fulfillments.new(
        fulfilled_at: fulfillment_date.strftime('%m/%d/%Y'),
        performer: performer,
        service_id: sparc_line_item.service.id,
        service_name: sparc_line_item.service.name,
        service_cost: line_item.cost(funding_source, fulfillment_date),
        funding_source: funding_source,
        quantity: fulfillment_time
      )

      if item[:fulfillment_component].present?
        fulfillment.components_data = [item[:fulfillment_component]]

        if fulfillment.save(validate: false)
          component = Component.new(
            component: item[:fulfillment_component],
            composable_id: fulfillment.id,
            composable_type: 'Fulfillment'
          )
          component.save
          fulfillment.reload
        end
      end

      if item[:fulfillment_notes].present?
        fulfillment.notes.new(comment: item[:fulfillment_notes], identity: performer)
      end

      fulfillment.save!
      successful_rows << row_num

    rescue StandardError => e
      failed_rows << { row: row_num, reason: e.message }
      puts " - Row #{row_num}: #{e.message}"
    end
  end

  success_count = successful_rows.count
  failure_count = failed_rows.count

  if failure_count == 0
    puts "All #{success_count} fulfillments added."
  else
    puts "#{success_count} fulfillments added."
    puts "#{failure_count} failed."
  end
end
