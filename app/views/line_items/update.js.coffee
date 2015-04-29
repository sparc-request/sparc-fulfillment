<% if @line_item_params[:quantity_requested] %>
$(".line_item[data-id=<%= @line_item.id %>] > .qty_rem").html("<%= @line_item.quantity_remaining %>")
<% end %>

$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");