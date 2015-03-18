$("#modal_area").html("<%= escape_javascript(render(:partial =>'task_reschedule_modal', locals: {task: @task})) %>");
$("#task_due_date").datetimepicker(format: 'YYYY-MM-DD')
$("#modal_place").modal 'show'