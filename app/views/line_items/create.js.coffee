$("#study_level_activities").html("<%= escape_javascript(render(:partial =>'protocols/study_level_activities', locals: {protocol: @protocol})) %>");
$('#otf_select').selectpicker()