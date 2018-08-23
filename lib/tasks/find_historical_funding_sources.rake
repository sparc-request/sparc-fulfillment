namespace :data do
  task find_historical_funding_sources: :environment do
    Protocol.find_each(batch_size: 100) do |p|
      begin
        funding_source = p.sparc_funding_source

        p.procedures.in_batches.update_all(funding_source: funding_source)
        p.fulfillments.in_batches.update_all(funding_source: funding_source)
        puts "Protocol ID: #{p.id}, SPARC Protocol ID: #{p.sparc_id} has had procedures and/or fulfillments updated."
      rescue
        puts "Protocol ID: #{p.id}, SPARC Protocol ID: #{p.sparc_id} is invalid"
        next
      end
    end
  end
end

