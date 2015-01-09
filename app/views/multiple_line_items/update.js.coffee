<% if @action == 'create' %>
<% @arm_hash.each do |key, value| %>
$(".arm_<%= key %>_end_of_core_<%= @core_id %>").before("<%= escape_javascript(render(:partial =>'service_calendar/line_item', locals: {line_item: value[:line_item], page: value[:page]})) %>")
<% end %>
<% end %>

<% if @action == 'destroy' %>
<% end %>

$("#line_item_modal").modal 'hide'
$("#flashes_container").html("<%= escape_javascript(render(:partial =>'shared/flash_messages')) %>");