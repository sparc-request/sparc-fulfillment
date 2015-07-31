<% @line_item_ids.each do |arm_id, li_ids| %>
<% li_ids.each do |li| %>
$("#line_item_<%= li %>").remove()
core_header = $("#arm_<%= arm_id %>_core_<%= @core_id %>")
if core_header.next().attr('id') == "arm_<%= arm_id %>_end_of_core_<%= @core_id %>"
  $("#arm_<%= arm_id %>_end_of_core_<%= @core_id %>").remove()
  core_header.remove()
<% end %>
<% end %>

$("#modal_place").modal 'hide'
$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");