json.(task)

json.user_name user_name(task.user_id)
json.task_type task.task_type
json.is_complete  format_checkbox(task.id)
json.participant_name task.participant_name
json.protocol_id task.protocol_id
json.visit_name task.visit_name
json.arm_name task.arm_name
json.task task.task
json.assignee_name user_name(task.assignee_id)
json.due_date format_date(task.due_date)
json.reschedule format_reschedule(task.id)
