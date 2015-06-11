<% if !(@procedure.errors.empty?) %>
$("#procedure_modal_errors").html("<%= escape_javascript(render(:partial =>'shared/modal_errors', locals: {errors: @procedure.errors})) %>")
<% else %>

update_complete_visit_button(<%= @procedure.appointment.can_finish? %>)

<% if @procedure.unstarted? or @procedure.follow_up? %>
$(".procedure[data-id='<%= @procedure.id %>']").
  find(".completed-date input").
  attr("disabled", true).
  attr("value", "")
$(".procedure[data-id='<%= @procedure.id %>']").
  find(".status label.active").removeClass("active")

<% elsif @procedure.incomplete? %>
$(".procedure[data-id='<%= @procedure.id %>']").
  find(".completed-date input").
  attr("disabled", true).
  attr("value", "")

<% elsif @procedure.complete? %>
$(".procedure[data-id='<%= @procedure.id %>']").
  find(".completed-date input").
  attr("disabled", false).
  attr("value", "<%= format_date(@procedure.completed_date) %>")
$(".completed_date_field").datetimepicker(format: 'MM-DD-YYYY')

<% end %>


$("#modal_place").modal 'hide'
<% end %>

