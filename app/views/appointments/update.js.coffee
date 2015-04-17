if "<%= @field %>" == "start_date"
  start_input_div = $('.start_date_input')
  if start_input_div.hasClass('hidden')
    $('.start_date_btn').addClass('hidden')
    start_input_div.removeClass('hidden')
    $('.complete_visit').removeClass('disabled')
    start_date_init("<%= format_datetime(@appointment.start_date) %>")

if "<%= @field %>" == "completed_date"
  $('table#completed-appointments-table').bootstrapTable('refresh', {url: "/appointments/completed_appointments.json?participant_id=<%= @appointment.participant_id %>", silent: "true"})
  completed_input_div = $('.completed_date_input')
  if completed_input_div.hasClass('hidden')
    $('.completed_date_btn').addClass('hidden')
    completed_input_div.removeClass('hidden')
    completed_date_init("<%= format_datetime(@appointment.completed_date) %>")
