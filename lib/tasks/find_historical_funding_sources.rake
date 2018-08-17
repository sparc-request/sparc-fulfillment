namespace :data do
  task find_historical_funding_sources: :environment do
    Protocol.all.each do |p|
      begin
        funding_source = p.sparc_funding_source

        p.procedures.update_all(funding_source: funding_source)
        p.fulfillments.update_all(funding_source: funding_source)
      rescue
        puts "Protocol ID: #{p.id}, SPARC Protocol ID: #{p.sparc_id} is invalid"
        next
      end
    end
  end
end

