json.(task)

json.id task.id
json.user_name task.identity.full_name
json.assignee_name task.assignee.full_name
json.complete format_checkbox(task)
json.body task.body
json.due_at format_date(task.due_at)
json.reschedule format_reschedule(task.id)
json.assignable_type format_task_type(task)
json.protocol_id format_task_protocol_id(task)
