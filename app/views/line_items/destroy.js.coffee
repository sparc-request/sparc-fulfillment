$("#flashes_container").html("<%= escape_javascript(render('flash')) %>")
<% if @line_item.deleted? %>
line_item = $(".line_item[data-id='<%= @line_item.id %>']")
line_item.next(".slide-toggle-hidden").remove()
line_item.next(".border").remove()
line_item.remove()
<% end %>
