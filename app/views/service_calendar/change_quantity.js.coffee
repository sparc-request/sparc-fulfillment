reset_quantity = (selector) ->
  $(selector).val($(selector).attr('previous_qty'))

save_quantity = (selector) ->
  $(selector).attr('previous_qty', $(selector).val())

<% if @visit.errors[:research_billing_qty].any? %>
error_tooltip_on("#visits_<%= @visit.id %>_research_billing_qty", "Quantity <%= raw(@visit.errors[:research_billing_qty][0]) %>")
reset_quantity("#visits_<%= @visit.id %>_research_billing_qty")
<% elsif @visit.errors[:insurance_billing_qty].any? %>
error_tooltip_on("#visits_<%= @visit.id %>_insurance_billing_qty", "Quantity <%= raw(@visit.errors[:insurance_billing_qty][0]) %>")
reset_quantity("#visits_<%= @visit.id %>_insurance_billing_qty")
<% else %>
save_quantity("#visits_<%= @visit.id %>_<%= @qty_type %>")
<% end %>

