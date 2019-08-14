task move_nexus_services: :environment do

  old_service_ids = [42,58,126,208,486,487,3548]
  new_service_id  = 37996
  new_service_name = 'Sample Processing'

  line_items = LineItem.where(service_id: old_service_ids)
  procedures = Procedure.where(service_id: old_service_ids)

  data_altered = CSV.open("tmp/data_altered.csv", "wb")
  data_altered << ['Type', 'ID', 'Old Service ID', 'Status', 'Completed Date']

  line_items.each do |item|
    started = item.appointments.map{ |appointment| appointment.started? }
    if !started.include?(true)
      puts "<>" * 20
      puts item.id
      puts "Updating item with service id of #{item.service_id}"
      data_altered << ['Line Item', item.id, item.service_id, '', '']
      item.update_attributes(service_id: new_service_id)
      puts "Items service id is now #{item.service_id}"
      puts "<>" * 20
    end
  end

  puts "-" * 100
  procedures.each do |procedure|
    if (procedure.status != 'complete')
      puts "<>" * 20
      puts procedure.id
      puts procedure.status
      puts procedure.service_id
      puts "<>" * 20
      data_altered << ['Procedure', procedure.id, procedure.service_id, procedure.status, '']
      procedure.update_attributes(service_id: new_service_id, service_name: new_service_name)
    elsif (procedure.status == 'complete') && (procedure.completed_date > "2019-7-1")
      puts "8" * 100
      puts procedure.status
      puts procedure.service_id
      puts procedure.completed_date
      puts "8" * 100 
      data_altered << ['Procedure', procedure.id, procedure.service_id, procedure.status, procedure.completed_date]
      procedure.update_attributes(service_id: new_service_id, service_name: new_service_name)
    end
  end
end