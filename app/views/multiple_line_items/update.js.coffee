<% if @action == 'create' %>
<% @arm_hash.each do |key, value| %>
end_of_core = $("#arm_<%= key %>_end_of_core_<%= @core_id %>")
if end_of_core.length == 0
  $("#end_of_arm_<%= key %>").before("<div id='arm_<%= key %>_core_<%= @core_id %>' class='row core'><div class='col-xs-12'>Core: <%= @core_name %></div></div><div id='arm_<%= key %>_end_of_core_<%= @core_id %>'></div>")
$("#arm_<%= key %>_end_of_core_<%= @core_id %>").before("<%= escape_javascript(render(:partial =>'service_calendar/line_item', locals: {line_item: value[:line_item], page: value[:page]})) %>")
<% end %>
<% end %>

<% if @action == 'destroy' %>
<% end %>

$("#line_item_modal").modal 'hide'
$("#flashes_container").html("<%= escape_javascript(render(:partial =>'shared/flash_messages')) %>");