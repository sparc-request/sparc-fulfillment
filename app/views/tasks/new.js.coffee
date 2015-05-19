$("#modal_area").html("<%= escape_javascript(render(partial: 'form', locals: {task: @task})) %>");
$("#follow_up_datepicker").datetimepicker(format: 'MM-DD-YYYY')
