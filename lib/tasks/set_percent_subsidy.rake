task set_percent_subsidy: :environment do

  protocols = Protocol.joins(sub_service_request: :subsidy)

  protocols.each do |protocol|
    puts "Updating subsidy for protocol #{protocol.id}"
    percent = protocol.sub_service_request.subsidy.percent_subsidy

    protocol.fulfillments.update_all(percent_subsidy: percent)

    protocol.procedures.update_all(percent_subsidy: percent)
  end
end