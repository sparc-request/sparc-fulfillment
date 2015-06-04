<% if @visit.errors[:research_billing_qty].any? %>
error_tooltip_on("#visits_<%= @visit.id %>_research_billing_qty", "Quantity <%= @visit.errors[:research_billing_qty].join(';') %>")
<% elsif @visit.errors[:insurance_billing_qty].any? %>
error_tooltip_on("#visits_<%= @visit.id %>_insurance_billing_qty", "Quantity <%= @visit.errors[:insurance_billing_qty].join(';') %>")
<% end %>
