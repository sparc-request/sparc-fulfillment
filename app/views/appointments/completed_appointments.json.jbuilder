json.(@appointments) do |appointment|
  json.name appointment.visit_group.name
  json.date appointment.completed_date.strftime("%m/%d/%y")
end