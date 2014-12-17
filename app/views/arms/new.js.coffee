$("#arm_form").html("<%= escape_javascript(render(:partial =>'protocols/study_schedule/add_arm_form', locals: {protocol: @protocol, arm: @arm})) %>");
