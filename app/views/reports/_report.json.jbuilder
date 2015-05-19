json.(report)

json.created_at format_date(report.created_at)
json.name report.name
json.status report.status
json.file attached_file_formatter(report)
