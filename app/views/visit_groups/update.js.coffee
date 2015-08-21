$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>");

<% if @visit_group.errors[:name].any? %>
# reset name field, if there was a validation error
$("#visit_group_<%= @visit_group.id %>").val("<%= @visit_group.reload.name %>")
error_tooltip_on("#visit_group_<%= @visit_group.id %>", "Name " + "<%= raw(@visit_group.errors[:name][0]) %>")
<% end %>

<% unless @errors %>
$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
$("#modal_place").modal 'hide'

$(".visit_dropdown option[value=<%= @visit_group.id %>]").text("- <%= @visit_group.name %>") #update page dropdown
$(".visit_dropdown").selectpicker('refresh')
$("#visit_group_<%= @visit_group.id %>").val("<%= @visit_group.name %>") #update visit group name input
$("#visit-before-display-<%= @visit_group.id %>").html("<%= @visit_group.window_before %>")
$("#visit-after-display-<%= @visit_group.id %>").html("<%= @visit_group.window_after %>")
$("#visit-day-display-<%= @visit_group.id %>").html("<%= @visit_group.day %>")
<% end %>
