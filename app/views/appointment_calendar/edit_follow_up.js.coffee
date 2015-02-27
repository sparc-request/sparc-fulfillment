$("#modal_area").html("<%= escape_javascript(render(:partial =>'follow_up_modal', locals: {procedure: @procedure, note: @note})) %>");
$("#modal_place").modal 'show'