$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>")

<% if @visit_group.errors[:name].any? %>
# reset name field, if there was a validation error
$("#visit_group_<%= @visit_group.id %>").val("<%= @visit_group.reload.name %>")
<% end %>

<% unless @errors %>
$("#flashes_container").html("<%= escape_javascript(render('flash')) %>")
$("#modal_place").modal 'hide'

# reload calendar
$(".schedule-tab.active a").click()
<% end %>
