$("#line_item_form").html("<%= escape_javascript(render(:partial =>'protocols/study_schedule/line_item_form', locals: {protocol: @protocol, line_item: @line_item, services: @services})) %>");
