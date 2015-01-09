<% if @action == 'create' %>
<% @arm_hash.each do |arm_id, value| %>
end_of_core = $("#arm_<%= arm_id %>_end_of_core_<%= @core_id %>")
if end_of_core.length == 0
  $("#end_of_arm_<%= arm_id %>").before("<div id='arm_<%= arm_id %>_core_<%= @core_id %>' class='row core'><div class='col-xs-12'>Core: <%= @core_name %></div></div><div id='arm_<%= arm_id %>_end_of_core_<%= @core_id %>'></div>")
$("#arm_<%= arm_id %>_end_of_core_<%= @core_id %>").before("<%= escape_javascript(render(:partial =>'service_calendar/line_item', locals: {line_item: value[:line_item], page: value[:page]})) %>")
<% end %>
<% end %>

<% if @action == 'destroy' %>
<% @line_item_ids.each do |arm_id, li_ids| %>
<% li_ids.each do |li| %>
$("#line_item_<%= li %>").replaceWith('')
core_headers = $("#arm_<%= arm_id %>_core_<%= @core_id %>")
alert core_headers.length
core_headers.each (header) ->
  if header.nextSibling.attr('id') == "arm_<%= arm_id %>_end_of_core_<%= @core_id %>"
    $("#arm_<%= arm_id %>_end_of_core_<%= @core_id %>").replaceWith('')
    header.replaceWith('')
<% end %>
<% end %>
<% end %>

$("#line_item_modal").modal 'hide'
$("#flashes_container").html("<%= escape_javascript(render(:partial =>'shared/flash_messages')) %>");