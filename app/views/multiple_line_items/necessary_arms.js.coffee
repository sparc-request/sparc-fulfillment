$(".arm-checkbox").hide()
<% if @arm_ids.any? %>
$(".no_arms_message").hide()
<% @arm_ids.each do |arm_id| %>
$("#arm_<%= arm_id.to_s %>_checkbox").show()
<% end %>
<% else %>
$(".no_arms_message").show()
<% end %>
