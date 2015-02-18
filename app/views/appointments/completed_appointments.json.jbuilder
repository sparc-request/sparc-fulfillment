json.(@appointments) do |appointment|
  json.name appointment.visit_group.name
  json.completed_date appointment.completed_date.strftime('%x')
end
