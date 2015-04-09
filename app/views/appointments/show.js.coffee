$(".appointments").html("<%= escape_javascript(render(partial: 'calendar', locals: {appointment: @appointment})) %>")

if !$('.start_date_input').hasClass('hidden')
  start_date_init("<%= format_datetime(@appointment.start_date) %>")

if !$('.completed_date_input').hasClass('hidden')
  completed_date_init("<%= format_datetime(@appointment.completed_date) %>")

<% @appointment.procedures.each do |procedure| %>
$(".date#<%= dom_id(procedure) %>").datetimepicker(format: 'YYYY-MM-DD', defaultDate: "<%= format_date(procedure.follow_up_date) %>")
<% end %>

$('#visit_indications').selectpicker()