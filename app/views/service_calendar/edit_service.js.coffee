$("#modal_area").html("<%= escape_javascript(render(:partial =>'change_service_modal', locals: {line_item: @line_item})) %>");
$("#modal_place").modal 'show'