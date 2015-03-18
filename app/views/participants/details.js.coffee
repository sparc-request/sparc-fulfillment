$("#modal_area").html("<%= escape_javascript(render(:partial =>'participants/details_modal', locals: {participant: @participant})) %>");
$("#modal_place").modal 'show'