$(".row.appointment-select").html("<%= escape_javascript(render(partial: 'participants/dropdown', locals: {participant: @appointment.participant})) %>")
if "<%= @field %>" == "start_date"
  start_input_div = $('.start_date_input')
  if start_input_div.hasClass('hidden')
    $('.start_date_btn').addClass('hidden')
    start_input_div.removeClass('hidden')

    update_complete_visit_button(<%= @appointment.can_finish? %>)

    start_date_init("<%= format_datetime(@appointment.start_date) %>")

if "<%= @field %>" == "completed_date"
  completed_input_div = $('.completed_date_input')
  if completed_input_div.hasClass('hidden')
    $('.completed_date_btn').addClass('hidden')
    completed_input_div.removeClass('hidden')
    completed_date_init("<%= format_datetime(@appointment.completed_date) %>")

if "<%= @field %>" == "completed_date" or "<%= @field %>" == "reset_completed_date"
  $('table#completed-appointments-table').bootstrapTable('refresh', {url: "/appointments/completed_appointments.json?participant_id=<%= @appointment.participant_id %>", silent: "true"})
