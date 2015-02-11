$("#appointment_modal_place").html("<%= escape_javascript(render(:partial =>'index_modal', locals: {procedure: @procedure})) %>");
$("#appointment_modal").modal 'show'
