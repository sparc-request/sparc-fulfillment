<% if !(@appointment.errors.empty?) %>
$("#appointment_modal_errors").html("<%= escape_javascript(render(:partial =>'shared/modal_errors', locals: {errors: @appointment.errors})) %>")
<% else %>
$("#modal_place").modal 'hide'
<% end %>
