json.total @total
json.rows @tasks do |task|
  json.id task.id
  json.identity_name task.identity.full_name
  json.assignee_name task.assignee.full_name
  json.complete format_task_checkbox(task)
  json.body task.body
  json.due_at format_task_due_date(task)
  json.reschedule format_task_reschedule(task.id)
  json.assignable_type format_task_type(task)
  json.protocol_id format_task_protocol_id(task)
  json.organization format_task_org(task)
end
