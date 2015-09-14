<% if @note && @note.errors.present? %>

$('#modal_errors').html("<%= escape_javascript(render(partial: 'modal_errors', locals: { errors: @note.errors })) %>")
$('#incomplete_all_modal button.save').removeClass('disabled')

<% else %>

<% if @procedures.present? %>

update_complete_visit_button(<%= @procedures.first.appointment.can_finish? %>)

$(".core[data-core-id='<%= @core_id %>'] .selectpicker.performed-by-dropdown").selectpicker('val', "<%= current_identity.id %>")

<% @procedures.each do |procedure| %>

<% if procedure.incomplete? %>

$("tr.procedure[data-id='<%= procedure.id %>'] td.status .incomplete").addClass('active')
$("tr.procedure[data-id='<%= procedure.id %>'] td.status .complete").removeClass('active')
$("tr.procedure[data-id='<%= procedure.id %>'] div.completed_date_field input.datetimepicker").val("").prop('disabled', true)
$("tr.procedure[data-id='<%= procedure.id %>'] td.performed-by .selectpicker").selectpicker('val', "<%= current_identity.id %>")
$('#modal_place').modal 'hide'

<% elsif procedure.complete? %>

$("tr.procedure[data-id='<%= procedure.id %>'] td.status .complete").addClass('active')
$("tr.procedure[data-id='<%= procedure.id %>'] td.status .incomplete").removeClass('active')
$("tr.procedure[data-id='<%= procedure.id %>'] div.completed_date_field input.datetimepicker").val("<%= @completed_date.strftime('%m-%d-%Y') %>").removeAttr("disabled")

<% end %>
<% end %>
<% end %>
<% end %>
