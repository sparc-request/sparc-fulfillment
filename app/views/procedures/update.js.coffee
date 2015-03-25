<% if @procedure.incomplete? %>
$(".procedure[data-id='<%= @procedure.id %>']").
  find(".completed-date input").
  attr("disabled", true).
  attr("value", "")
<% elsif @procedure.complete? %>
$(".procedure[data-id='<%= @procedure.id %>']").
  find("input").
  attr("disabled", false).
  attr("value", "<%= format_date(@procedure.completed_date) %>")
<% end %>

$("#modal_place").modal 'hide'
