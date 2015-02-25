$("#modal_area").html("<%= escape_javascript(render(:partial =>'incomplete_procedure_modal', locals: {procedure: @procedure}))%>");
$("#modal_place").modal 'show'
