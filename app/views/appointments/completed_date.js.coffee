$('table#completed-appointments-table').bootstrapTable('refresh', {url: "/appointments/completed_appointments.json?participant_id=<%= @appointment.participant_id %>", silent: "true"})

completed_input_div = $('.completed_date_input')
completed_btn_div = $('.completed_date_btn')
if completed_input_div.hasClass('hidden')
  completed_btn_div.addClass('hidden')
  completed_input_div.removeClass('hidden')
  $('#completed_date').datetimepicker(defaultDate: "<%= format_datetime(@appointment.completed_date) %>")
  $('#completed_date').on 'dp.hide', (e) ->
    appointment_id = $(this).attr('appointment_id')
    $.ajax
      type: 'PATCH'
      url:  "/appointments/#{appointment_id}/completed_date?new_date=#{e.date}"