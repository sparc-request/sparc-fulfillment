json.(@appointments) do |appointment|
  json.id appointment.id
  json.name appointment.name
  json.completed_date appointment.completed_date.strftime('%m/%d/%Y')
  json.arm appointment.arm.name
end
