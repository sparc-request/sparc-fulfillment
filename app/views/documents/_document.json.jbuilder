json.(document)

json.created_at format_document_date(document.created_at)
json.state document.state
json.file attached_file_formatter(document)
json.title document.title
json.read_state read_formatter(document)
json.actions actions_formatter(document)
