$("#modal_area").html("<%= escape_javascript(render(:partial =>'study_level_activities/line_item_form', locals: {protocol: @protocol, line_item: @line_item, header_text: 'Edit Study Level Activity'})) %>");
$("#modal_place").modal 'show'
$("#date_started_field").datetimepicker(format: 'MM-DD-YYYY')
$(".selectpicker").selectpicker()
