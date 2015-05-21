json.(@appointments) do |appointment|
  json.name format_name(appointment)
  json.completed_date appointment.completed_date.strftime('%x')
end
