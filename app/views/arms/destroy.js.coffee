$("#flashes_container").html("<%= escape_javascript(render('application/flash')) %>")
<% if @delete %>
remove_arm("<%= @arm.id %>")
<% elsif @has_completed_data %>
alert("This arm has completed procedures and cannot be deleted")
<% end %>
