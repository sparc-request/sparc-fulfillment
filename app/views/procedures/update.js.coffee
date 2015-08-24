<% if @procedure.errors.present? %>
$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @procedure.errors})) %>")
<% else %>

update_complete_visit_button(<%= @procedure.appointment.can_finish? %>)

date_time_picker = $(".procedure[data-id='<%= @procedure.id %>']").
  find(".completed_date_field").
  datetimepicker(format: 'MM-DD-YYYY').
  data("DateTimePicker")

<% if @procedure.unstarted? || @procedure.follow_up? %>
date_time_picker.
  date(null).
  disable()
$(".procedure[data-id='<%= @procedure.id %>']").
  find(".status label.active").removeClass("active")

<% elsif @procedure.incomplete? %>
date_time_picker.
  date(null).
  disable()

$("table.procedures tbody tr[data-id='<%= @procedure.id %>'] td.performed-by .selectpicker").selectpicker('val', '<%= @procedure.performer_id %>')

<% elsif @procedure.complete? %>
date_time_picker.
  date("<%= format_date(@procedure.completed_date) %>").
  enable()
$("table.procedures tbody tr[data-id='<%= @procedure.id %>'] td.performed-by .selectpicker").
  selectpicker('val', '<%= @procedure.performer_id %>')

<% end %>

$("#modal_place").modal 'hide'
<% end %>
