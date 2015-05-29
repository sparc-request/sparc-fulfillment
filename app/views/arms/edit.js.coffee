$("#modal_area").html("<%= escape_javascript(render(:partial =>'/protocols/study_schedule/edit_arm_form', locals: {arm: @arm, services: @services})) %>");
$(".selectpicker").selectpicker()
$("#modal_place").modal 'show'