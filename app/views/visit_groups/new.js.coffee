$("#modal_area").html("<%= escape_javascript(render(:partial =>'study_schedule/management/manage_visits/add_visit_form', locals: {protocol: @protocol, visit_group: @visit_group, schedule_tab: @schedule_tab, current_page: 1})) %>");
$("#modal_place").modal 'show'
$(".selectpicker").selectpicker()
