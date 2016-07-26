$('.appointments').html("<%= escape_javascript(render(partial: '/appointments/calendar', locals: { appointment: @appointment })) %>")
$(".row.appointment-select").html("<%= escape_javascript(render(partial: 'participants/dropdown', locals: {participant: @appointment.participant})) %>")

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

$(".completed_date_field").datetimepicker
  format: 'MM/DD/YYYY'
  ignoreReadonly: true

$('.row.appointment [data-toggle="tooltip"]').tooltip()

<% if @refresh_dashboard %>
$('table#completed-appointments-table').bootstrapTable('refresh', {url: "/appointments/completed_appointments.json?participant_id=<%= @appointment.participant_id %>", silent: "true"})
<% end %>
