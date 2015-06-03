$("#modal_area").html("<%= escape_javascript(render(:partial =>'service_calendar/study_schedule/change_service_form', locals: {line_item: @line_item})) %>");
$(".selectpicker").selectpicker()
$("#modal_place").modal 'show'