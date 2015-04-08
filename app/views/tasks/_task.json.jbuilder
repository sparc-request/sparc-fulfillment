json.(task)

json.id task.id
json.user_name task.user.full_name
json.assignee_name task.assignee.full_name
json.complete format_checkbox(task)
json.body task.body
json.due_at format_date(task.due_at)
json.reschedule format_reschedule(task.id)
json.assignable_type task.assignable_type
