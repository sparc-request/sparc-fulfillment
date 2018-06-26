namespace :data do
  task find_historical_funding_sources: :environment do
    procedures = Procedure.all
    fulfillments = Fulfillment.all

    procedures.find_each do |procedure|
      funding_source = procedure.protocol.sparc_funding_source
      procedure.update_attribute(:funding_source, funding_source)
    end

    fulfillments.find_each do |fulfillment|
      funding_source = fulfillment.protocol.sparc_funding_source
      unless funding_source.nil?
        fulfillment.update_attribute(:funding_source, funding_source)
      end
    end
  end
end

