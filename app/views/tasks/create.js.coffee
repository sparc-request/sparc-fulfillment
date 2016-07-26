<% if @errors.present? %>
$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>")

<% else %>
if !$('.notification.task-notifications').length
  $('<span class="notification task-notifications"></span>').appendTo($('a.tasks'))
$(".notification.task-notifications").empty().append("<%= current_identity.reload.tasks_count %>")
$("#flashes_container").html("<%= escape_javascript(render('flash')) %>")
$('#task-list').bootstrapTable('refresh', {silent: "true"})
$("#modal_place").modal 'hide'

<% if @procedure.present? %>
$("#follow_up_<%= @procedure.id %>").html("<%= escape_javascript(render(:partial =>'appointments/followup_calendar', locals: {procedure: @procedure})) %>")
update_complete_visit_button(<%= @procedure.appointment.can_finish? %>)
<% end %>

<% if @appointment.present? %>
$('.appointments').html("<%= escape_javascript(render(partial: '/appointments/calendar', locals: { appointment: @appointment })) %>")

pg = new ProcedureGrouper()
pg.initialize()

if !$('.start_date_input').hasClass('hidden')
  start_date_init("<%= format_datetime(@appointment.start_date) %>")

if !$('.completed_date_input').hasClass('hidden')
  completed_date_init("<%= format_datetime(@appointment.completed_date) %>")

$('#appointment_content_indications').selectpicker()
$('#appointment_content_indications').selectpicker('val', "<%= @appointment.contents %>")
$(".selectpicker").selectpicker()

statuses = []
<% @statuses.each do |status| %>
statuses[statuses.length] =  "<%= status %>"
<% end %>

$('#appointment_indications').selectpicker()
$('#appointment_indications').selectpicker('val', statuses)

$(".followup_procedure_datepicker").datetimepicker
  format: 'MM/DD/YYYY'
  ignoreReadonly: true

$(".completed_date_field").datetimepicker(format: 'MM/DD/YYYY')

$('.row.appointment [data-toggle="tooltip"]').tooltip()
<% end %>

$(".followup_procedure_datepicker").datetimepicker(format: 'MM/DD/YYYY')
<% end %>
