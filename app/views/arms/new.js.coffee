$("#modal_area").html("<%= escape_javascript(render(:partial =>'study_schedule/management/manage_arms/add_arm_form', locals: {protocol: @protocol, arm: @arm, current_page: @current_page, services: @services, schedule_tab: @schedule_tab})) %>");
$(".selectpicker").selectpicker()
$("#modal_place").modal 'show'