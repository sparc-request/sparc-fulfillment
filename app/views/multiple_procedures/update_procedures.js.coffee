<% if @note && @note.errors.present? %>

$('#modal_errors').html("<%= escape_javascript(render(partial: 'modal_errors', locals: { errors: @note.errors })) %>")
$('#incomplete_all_modal button.save').removeClass('disabled')

<% else %>

$('#complete_all_modal button.save').removeClass('disabled')

<% if @procedures.present? %>

update_complete_visit_button(<%= @procedures.first.appointment.can_finish? %>)

$(".core[data-core-id='<%= @core_id %>'] .selectpicker.performed-by-dropdown").selectpicker('val', "<%= current_identity.id %>")

<% @procedures.each do |procedure| %>

<% if procedure.incomplete? %>

$("tr.procedure[data-id='<%= procedure.id %>'] td.status .incomplete").addClass('active')
$("tr.procedure[data-id='<%= procedure.id %>'] td.status .complete").removeClass('active')
$("tr.procedure[data-id='<%= procedure.id %>'] .completed_date_field").val("").prop('disabled', true)
$("tr.procedure[data-id='<%= procedure.id %>'] td.performed-by .selectpicker").selectpicker('val', "<%= @performed_by %>")
<% if procedure.notes.any? %>
$("tr.procedure[data-id='<%= procedure.id %>'] td.notes .btn").removeClass('btn-default')
$("tr.procedure[data-id='<%= procedure.id %>'] td.notes .btn").addClass('btn-primary')
$("tr.procedure[data-id='<%= procedure.id %>'] td.notes .btn .glyphicon").removeClass('blue-notes')
$('#modal_place').modal 'hide'
<% end %>

<% elsif procedure.complete? %>
$("tr.procedure[data-id='<%= procedure.id %>'] td.status .complete").addClass('active')
$("tr.procedure[data-id='<%= procedure.id %>'] td.status .incomplete").removeClass('active')
$("tr.procedure[data-id='<%= procedure.id %>'] .completed-date .completed_date_field.datetimepicker").val("<%= @completed_date %>").removeAttr("disabled")
$("tr.procedure[data-id='<%= procedure.id %>'] td.performed-by .selectpicker").selectpicker('val', "<%= @performed_by %>")
<% if procedure.notes.any? %>
$("tr.procedure[data-id='<%= procedure.id %>'] td.notes .btn").removeClass('btn-default')
$("tr.procedure[data-id='<%= procedure.id %>'] td.notes .btn").addClass('btn-primary')
$("tr.procedure[data-id='<%= procedure.id %>'] td.notes .btn .glyphicon").removeClass('blue-notes')

$("#modal_place").modal('hide')
<% end %>
<% end %>
<% end %>
<% end %>
<% end %>

