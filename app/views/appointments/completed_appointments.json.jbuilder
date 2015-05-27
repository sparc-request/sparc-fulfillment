json.(@appointments) do |appointment|
  json.name appointment.name
  json.completed_date appointment.completed_date.strftime('%x')
end
