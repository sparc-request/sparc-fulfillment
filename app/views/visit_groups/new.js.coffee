$("#modal_area").html("<%= escape_javascript(render(:partial =>'protocols/study_schedule/add_visit_form', locals: {protocol: @protocol, visit_group: @visit_group, calendar_tab: @calendar_tab, current_page: 1})) %>");
$("#modal_place").modal 'show'
$(".selectpicker").selectpicker()
