$("#modal_place").modal 'hide'
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

$(".followup_procedure_datepicker").datetimepicker(format: 'MM/DD/YYYY')
$(".completed_date_field").datetimepicker(format: 'MM/DD/YYYY')

$('.row.appointment [data-toggle="tooltip"]').tooltip()
<% elsif @line_item.present? %>
$("#list-<%= @line_item.id %>").trigger('click')
<% else %>
$('table#participants-tracker-table').bootstrapTable('refresh', {silent: true})
<% end %>
