desc "Break out line items into new protocols"
task service_move: :environment do
  sparc_service_ids = [34054, 34055, 34056]
  ActiveRecord::Base.transaction do
    CSV.foreach('tmp/doxy_ssrs.csv', :headers => true) do |row|
      original_protocol = Protocol.find_by_sub_service_request_id(row['Original SSR'].to_i)
      puts "Creating new protocol for #{original_protocol.sub_service_request_id}"
      new_protocol = Protocol.new(sparc_id: original_protocol.sparc_id,
                                  sponsor_name: original_protocol.sponsor_name,
                                  udak_project_number: original_protocol.udak_project_number,
                                  start_date: original_protocol.start_date,
                                  end_date: original_protocol.end_date,
                                  recruitment_start_date: original_protocol.recruitment_start_date,
                                  recruitment_end_date: original_protocol.recruitment_end_date,
                                  study_cost: original_protocol.study_cost,
                                  sub_service_request_id: row['New SSR'].to_i
                                  )
      new_protocol.save(validate: false)
      puts "New protocol created #{new_protocol.id}"
      original_protocol.line_items.each do |line_item|
        if sparc_service_ids.include?(line_item.service_id)
          puts "Moving line item #{line_item.id}"
          line_item.protocol_id = new_protocol.id
          line_item.save(validate: false)
        end
      end
    end
  end
end