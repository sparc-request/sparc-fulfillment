json.(document)

json.created_at format_document_date(document.created_at)
json.state document.state
json.file attached_file_formatter(document)
json.title document.title
json.viewed_at format_document_date(document.last_accessed_at)
json.edit edit_formatter(document)
json.delete delete_formatter(document)
