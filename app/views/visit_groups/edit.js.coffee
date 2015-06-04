$("#modal_area").html("<%= escape_javascript(render(:partial =>'/service_calendar/calendar_management/edit_visit_form', locals: {protocol: @protocol, visit_group: @visit_group})) %>");
$(".selectpicker").selectpicker()
$("#modal_place").modal 'show'