$("#flashes_container").html("<%= escape_javascript(render('application/flash')) %>")
<% if @delete %>
remove_arm("<%= @arm.id %>")
$("#manage_visit_groups").empty()
$("#manage_visit_groups").html("<%= escape_javascript(render partial: '/study_schedule/study_schedule_management/visit_groups_selectpicker', locals: {arms: @arms}) %>")
$(".selectpicker").selectpicker()
<% elsif @has_completed_data %>
alert("This arm has completed procedures and cannot be deleted")
<% end %>
