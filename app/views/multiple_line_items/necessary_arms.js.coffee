$(".arm-checkbox").hide()
<% @arm_ids.each do |arm_id| %>
$("#arm_<%= arm_id.to_s %>_checkbox").show()
<% end %>