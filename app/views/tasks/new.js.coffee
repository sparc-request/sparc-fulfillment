$("#modal_area").html("<%= escape_javascript(render(partial: 'form', locals: {task: @task})) %>");
$("#follow_up_date").datetimepicker(format: 'YYYY-MM-DD')
