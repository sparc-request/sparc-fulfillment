$("#modal_area").html("<%= escape_javascript(render(partial: 'edit', locals: { procedure: @procedure, task: @task})) %>")
$("#task_due_at").datetimepicker(format: 'MM-DD-YYYY')
$("#modal_place").modal 'show'
