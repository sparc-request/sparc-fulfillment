$("#modal_area").html("<%= escape_javascript(render(:partial =>'new_note_modal', locals: {procedure: @procedure, note: @note})) %>");
$("#modal_place").modal 'show'