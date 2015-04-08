$("#modal_area").html("<%= escape_javascript(render(:partial =>'task_reschedule_modal', locals: {task: @task})) %>");
$("#task_due_at").datetimepicker(format: 'MM-DD-YYYY', keepOpen: true)
$("#modal_place").modal 'show'
