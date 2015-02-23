$("#modal_area").html("<%= escape_javascript(render(:partial =>'index_modal', locals: {procedure: @procedure})) %>");
$("#modal_place").modal 'show'
