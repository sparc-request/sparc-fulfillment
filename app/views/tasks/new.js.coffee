$("#modal_area").html("<%= escape_javascript(render(partial: 'form', locals: {task: @task})) %>");
$("#task_due_at").datetimepicker(format: 'MM-DD-YYYY')
