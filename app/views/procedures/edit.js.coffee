$("#modal_area").html("<%= escape_javascript(render(partial: 'edit', locals: { procedure: @procedure, task: @task})) %>")
$("#follow_up_procedure_datepicker").datetimepicker(format: 'MM-DD-YYYY')
$("#modal_place").modal 'show'
