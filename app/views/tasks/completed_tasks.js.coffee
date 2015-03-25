$("#modal_area").html("<%= escape_javascript(render(:partial =>'completed_tasks_modal', locals: {completed_tasks: @completed_tasks})) %>");
$("#modal_place").modal 'show'
