json.(@imports) do |import|
  json.created_at   format_document_date(import.created_at)
  json.file         attached_file(import)
  json.title        "#{import.title} "
end
