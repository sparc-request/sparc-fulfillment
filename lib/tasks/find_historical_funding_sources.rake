namespace :data do
  task find_historical_funding_sources: :environment do
    procedures = Procedure.all
    fulfillments = Fulfillment.all

    procedures.find_each do |procedure|
      protocol = Sparc::Protocol.find(procedure.protocol.sparc_id)
      funding_source = protocol.funding_source
      unless funding_source.nil?
        procedure.update_attribute(:funding_source, funding_source)
      end
    end

    fulfillments.find_each do |fulfillment|
      protocol = Sparc::Protocol.find(fulfillment.protocol.sparc_id)
      funding_source = protocol.funding_source
      unless funding_source.nil?
        fulfillment.update_attribute(:funding_source, funding_source)
      end
    end
  end
end

