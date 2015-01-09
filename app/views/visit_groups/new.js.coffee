$("#visit_form").html("<%= escape_javascript(render(:partial =>'protocols/study_schedule/add_visit_form', locals: {visit_group: @visit_group, arm: @arm, current_page: @current_page})) %>");
