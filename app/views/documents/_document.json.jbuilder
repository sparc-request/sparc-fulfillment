json.(document)

json.created_at format_document_date(document.created_at)
json.state document.state
json.file attached_file_formatter(document)
json.title document.title
json.read_state read_formatter(document.last_accessed_at)
json.edit edit_formatter(document)
json.delete delete_formatter(document)
