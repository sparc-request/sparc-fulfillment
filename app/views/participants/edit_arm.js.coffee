$("#modal_area").html("<%= escape_javascript(render(:partial =>'participants/change_arm_form', locals: {protocol: @protocol, participant: @participant})) %>");
$("#modal_place").modal 'show'