<% if @visit.errors %> # qty change failed, reset to previous qty
<% @visit.reload %>
$("#visits_<%= @visit.id %>_research_billing_qty").val("<%= @visit.research_billing_qty %>")
$("#visits_<%= @visit.id %>_insurance_billing_qty").val("<%= @visit.insurance_billing_qty %>")

<% if @visit.errors[:research_billing_qty].any? %>
error_tooltip_on("#visits_<%= @visit.id %>_research_billing_qty", "Quantity <%= raw(@visit.errors[:research_billing_qty][0]) %>")
reset_quantity("#visits_<%= @visit.id %>_research_billing_qty")
<% elsif @visit.errors[:insurance_billing_qty].any? %>
error_tooltip_on("#visits_<%= @visit.id %>_insurance_billing_qty", "Quantity <%= raw(@visit.errors[:insurance_billing_qty][0]) %>")
reset_quantity("#visits_<%= @visit.id %>_insurance_billing_qty")
<% end %>

<% end %>