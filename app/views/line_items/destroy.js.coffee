$("#flashes_container").html("<%= escape_javascript(render('flash')) %>")
<% if @line_item.deleted? %>
$(".line_item_container[data-id='<%= @line_item.id %>']").remove()
<% end %>
