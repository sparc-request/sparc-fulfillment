$("#modal_area").html("<%= escape_javascript(render(partial: @partial, locals: {task: @task})) %>")
$("#modal_place").modal 'show'
