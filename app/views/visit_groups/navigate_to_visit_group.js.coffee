$("#modal_area").html("<%= escape_javascript(render(:partial =>'/study_schedule/management/manage_visits/navigate_visit_form', locals: {intended_action: @intended_action, protocol: @protocol, arm: @arm, visit_group: @visit_group })) %>")
$(".selectpicker").selectpicker()
$("#modal_place").modal 'show'
