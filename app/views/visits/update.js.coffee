<% if @visit.errors[:research_billing_qty].any? %>
error_tooltip_on("#visits_<%= @visit.id %>_research_billing_qty", "Quantity <%= raw(@visit.errors[:research_billing_qty][0]) %>")
$("#visits_<%= @visit.id %>_research_billing_qty").val("<%= @visit.reload.research_billing_qty %>")
<% elsif @visit.errors[:insurance_billing_qty].any? %>
error_tooltip_on("#visits_<%= @visit.id %>_insurance_billing_qty", "Quantity <%= raw(@visit.errors[:insurance_billing_qty][0]) %>")
$("#visits_<%= @visit.id %>_insurance_billing_qty").val("<%= @visit.reload.insurance_billing_qty %>")
<% end %>
