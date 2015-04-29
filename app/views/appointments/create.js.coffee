<% if !(@appointment.errors.empty?) %>
$("#appointment_modal_errors").html("<%= escape_javascript(render(partial: 'shared/modal_errors', locals: {errors: @appointment.errors})) %>")
<% else %>
$(".row.appointment-select").html("<%= escape_javascript(render(partial: 'participants/dropdown', locals: {participant: @appointment.participant})) %>")
$("#appointment_select").selectpicker()
$("#modal_place").modal 'hide'
<% end %>
