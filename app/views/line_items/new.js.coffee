$("#modal_area").html("<%= escape_javascript(render(:partial =>'study_level_activities/study_level_activity_form', locals: {protocol: @protocol, line_item: @line_item, header_text: t(:line_item)[:create]})) %>");
$("#modal_place").modal 'show'
$("#date_started_field").datetimepicker(format: 'MM-DD-YYYY')
$(".selectpicker").selectpicker()
