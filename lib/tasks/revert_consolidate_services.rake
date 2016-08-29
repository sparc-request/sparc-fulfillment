namespace :data do
  desc "Revert migrating services from 486,487 to 36"
  task revert_consolidation: :environment do
    class HistoricalProcedure < ActiveRecord::Base
      self.table_name = 'procedures'
      octopus_establish_connection(Octopus.config[:development][:recovery])
      allow_shard :recovery
    end

    Procedure.transaction do
      CSV.open("tmp/reverted_procedures.csv", "wb") do |csv|
        csv << ['procedure id', 'old service id', 'new service id', 'old service name', 'new service name']
        HistoricalProcedure.where(service_id: [486,487], status: ['unstarted', 'incomplete']).each do |hp|
          proc = Procedure.where(id: hp.id).first

          if proc
            if hp.service_id != proc.service_id
              csv << [proc.id, proc.service_id, hp.service_id, proc.service_name, hp.service_name]
              proc.update_attributes(service_id: hp.service_id, service_name: hp.service_name)
            end
          end
        end
      end
    end
  end
end
