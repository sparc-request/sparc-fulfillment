$("#modal_area").html("<%= escape_javascript(render(:partial =>'study_schedule/management/manage_visits/add_visit_form', locals: {protocol: @protocol, visit_group: @visit_group, arm: @arm, schedule_tab: @schedule_tab, current_page: @current_page})) %>")
$("#modal_place").modal 'show'
$(".selectpicker").selectpicker()
