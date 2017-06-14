json.(@appointments) do |appointment|
  json.id appointment.id
  json.name appointment.formatted_name
  json.completed_date format_date(appointment.completed_date)
  json.arm appointment.arm.name
end
