<% if @intended_action == "edit" %>
$("#modal_area").html("<%= escape_javascript(render(:partial =>'/study_schedule/management/manage_arms/edit_arm_form', locals: {arm: @arm, protocol_arms: @protocol.arms})) %>");
<% elsif @intended_action == "destroy" %>
$("#modal_area").html("<%= escape_javascript(render(:partial =>'/study_schedule/management/manage_arms/remove_arm_form', locals: {arm: @arm, protocol_arms: @protocol.arms})) %>");
<% end %>
$(".selectpicker").selectpicker()
$("#modal_place").modal 'show'