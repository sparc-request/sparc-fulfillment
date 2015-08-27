<% if @note && @note.errors.present? %>
##Display any errors if there are any first
$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @note.errors})) %>")
$("#incomplete_all_modal button.save").removeClass("disabled")
<% else %>
##No errors, remove active classes and set performed by, no matter what the status is.
update_complete_visit_button(<%= @appointment.can_finish? %>)
$(".core[data-core-id='<%= @core_id %>'] td.status label.btn").removeClass('active')
$(".core[data-core-id='<%= @core_id %>'] .selectpicker.performed-by-dropdown").selectpicker('val', "<%= current_identity.id %>")

<% if @status == "incomplete" %>
$(".core[data-core-id='<%= @core_id %>'] td.status .incomplete").addClass('active')
$(".core[data-core-id='<%= @core_id %>'] div.completed_date_field input.datetimepicker").val("").prop('disabled', true)
$(".core[data-core-id='<%= @core_id %>'] td.performed-by .selectpicker").selectpicker('val', "<%= current_identity.id %>")
$("#modal_place").modal 'hide'

<% elsif @status == "complete" %>
$(".core[data-core-id='<%= @core_id %>'] td.status .complete").addClass('active')
$(".core[data-core-id='<%= @core_id %>'] div.completed_date_field input.datetimepicker").val("<%= @completed_date.strftime('%m-%d-%Y') %>").removeAttr("disabled")

<% end %>
<% end %>
