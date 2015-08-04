$("#flashes_container").html("<%= escape_javascript(render('flash')) %>")
<% if @line_item.deleted? %>
$(".line_item[data-id='<%= @line_item.id %>']").parent("div.line_item_container").remove()
<% end %>
