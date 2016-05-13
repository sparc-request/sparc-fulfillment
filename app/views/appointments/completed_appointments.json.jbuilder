json.(@appointments) do |appointment|
  json.id appointment.id
  json.name appointment.name
  json.completed_date appointment.completed_date.strftime('%x')
  json.arm appointment.arm.name
end
