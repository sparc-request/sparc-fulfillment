$("#flashes_container").html("<%= escape_javascript(render('application/flash')) %>")
<% if @visit.errors %> # qty change failed, reset to previous qty
<% @visit.reload %>
$("#visits_<%= @visit.id %>_research_billing_qty").val("<%= @visit.research_billing_qty %>")
$("#visits_<%= @visit.id %>_insurance_billing_qty").val("<%= @visit.insurance_billing_qty %>")
<% end %>