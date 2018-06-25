namespace :data do
  task find_historical_funding_sources: :environment do
    procedures = Procedure.all
    fulfillments = Fulfillment.all

    procedures.find_each do |procedure|
      procedure_protocol = procedure.protocol
      sparc_protocol = Sparc::Protocol.find_by(id: procedure_protocol.sparc_id)
      procedure.update_attribute(:funding_source, sparc_protocol.funding_source)
    end

    fulfillments.find_each do |fulfillment|
      fulfillment_protocol = fulfillment.protocol
      unless fulfillment_protocol.nil?
        sparc_protocol = Sparc::Protocol.find_by(id: fulfillment_protocol.sparc_id)
        fulfillment.update_attribute(:funding_source, sparc_protocol.funding_source)
      end
    end
  end
end

