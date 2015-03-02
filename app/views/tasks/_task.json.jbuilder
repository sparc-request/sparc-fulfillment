json.(task)

json.created_by task.created_by
json.completed  task.is_complete
json.participant_name task.participant_name
json.protocol_id task.protocol_id
json.visit_name task.visit_name
json.arm_name task.arm_name
json.task task.task
json.assignment task.assignment
json.due_date format_date(task.due_date)
