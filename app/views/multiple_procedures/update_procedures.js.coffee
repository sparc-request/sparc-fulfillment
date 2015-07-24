<% if @note && @note.errors.present? %>
##Display any errors if there are any first
$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @note.errors})) %>")
<% else %>
##No errors, remove active classes and set performed by, no matter what the status is.
$(".core[data-core-id='<%= @core_id %>'] td.status label.btn").removeClass('active')
$(".core[data-core-id='<%= @core_id %>'] .selectpicker.performed-by-dropdown").selectpicker('val', "<%= current_identity.id %>")

<% if @status == "incomplete" %>
$(".core[data-core-id='<%= @core_id %>'] td.status .incomplete").addClass('active')
$("#modal_place").modal 'hide'

<% elsif @status == "complete" %>
$(".core[data-core-id='<%= @core_id %>'] td.status .complete").addClass('active')
$(".core[data-core-id='<%= @core_id %>'] div.completed_date_field input.datetimepicker").val("<%= format_datetime(@completed_date) %>").removeAttr("disabled")

<% end %>
<% end %>
