$("#modal_area").html("<%= escape_javascript(render(:partial =>'/study_schedule/management/manage_arms/navigate_arm_form', locals: {intended_action: @intended_action, arm: @arm, protocol_arms: @protocol.arms})) %>");
$(".selectpicker").selectpicker()
$("#modal_place").modal 'show'