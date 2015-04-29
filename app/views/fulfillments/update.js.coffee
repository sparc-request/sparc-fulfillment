<% if @fulfillment_params[:quantity] %>
$(".line_item[data-id=<%= @fulfillment.line_item_id %>] > .qty_rem").html("<%= @fulfillment.line_item.quantity_remaining %>")
<% end %>

<% if @fulfillment_params[:fulfilled_at] %>
$(".line_item[data-id=<%= @fulfillment.line_item_id %>] > .last_fulfillment").html("<%= format_date(@fulfillment.line_item.last_fulfillment) %>")
<% end %>

$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");