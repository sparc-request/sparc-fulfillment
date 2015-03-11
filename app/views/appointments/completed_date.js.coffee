$('table#completed-appointments-table').bootstrapTable('refresh', {url: "/appointments/completed_appointments.json?participant_id=<%= @appointment.participant_id %>", silent: "true"})

$('#completed_date').val("<%= @appointment.completed_date %>")

completed_input_div = $('.completed_date_input')
completed_btn_div = $('.completed_date_btn')
if completed_input_div.hasClass('hidden')
  completed_btn_div.addClass('hidden')
  completed_input_div.removeClass('hidden')