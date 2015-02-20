$("#change_service_form").html("<%= escape_javascript(render(:partial =>'change_service_modal', locals: {line_item: @line_item})) %>");
$("#change_service_modal").modal 'show'