<% if !(@errors.nil?) %>
$("#procedure_modal_errors").html("<%= escape_javascript(render(:partial =>'shared/modal_errors', locals: {errors: @errors})) %>");
<% else %>
<% if @procedure.reset? %>
$(".procedure[data-id='<%= @procedure.id %>']").
  find(".completed-date input").
  attr("disabled", true).
  attr("value", "")
$(".procedure[data-id='<%= @procedure.id %>']").
  find(".status label.complete").
  removeClass('active')
$(".procedure[data-id='<%= @procedure.id %>']").
  find(".status label.incomplete").
  removeClass('active')
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
<% end %>


$("#modal_place").modal 'hide'
<% end %>

