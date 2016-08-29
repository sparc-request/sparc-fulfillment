namespace :data do
  desc "Revert procedures from CSV"
  task revert_procedures_from_csv: :environment do
    #### csv location tmp/reverted_procedures.csv
    #### procedure id,old service id,new service id,old service name,new service name

    CSV.open("tmp/updated_procedures.csv", "wb") do |csv|
      csv << ['action', 'procedure id', 'old service id', 'new service id', 'old service name', 'new service name']

      CSV.foreach("tmp/reverted_procedures.csv", headers: true) do |row|
        procedure = Procedure.find row['procedure id']
        old_service_id = procedure.service_id
        old_service_name = procedure.service_name
        if procedure.update_attributes(service_id: row['new service id'], service_name: row['new service name'])
          csv << ['Success', procedure.id, old_service_id, procedure.service_id, old_service_name, procedure.service_name]
        else
          csv << ['Failed', procedure.id]
        end
      end
    end
  end
end
