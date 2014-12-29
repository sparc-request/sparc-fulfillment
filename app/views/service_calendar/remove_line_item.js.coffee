$("#line_item_<%= @line_item_id %>").remove()
if <%= @remove_core == true %>
  $("#arm_<%= @arm_id %>_core_<%= @core_id %>").remove()