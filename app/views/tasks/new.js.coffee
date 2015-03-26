$("#modal_area").html("<%= escape_javascript(render(partial: 'form', locals: {task: @task})) %>");
$("#task_due_at").datetimepicker(format: 'YYYY-MM-DD')
