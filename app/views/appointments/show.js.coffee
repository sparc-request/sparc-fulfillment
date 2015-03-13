$(".appointment").html("<%= escape_javascript(render(partial: 'calendar', locals: {appointment: @appointment})) %>")

if !$('.start_date_input').hasClass('hidden')
  $('#start_date').datetimepicker(defaultDate: "<%= format_datetime(@appointment.start_date) %>")
  $('#start_date').on 'dp.hide', (e) ->
    appointment_id = $(this).attr('appointment_id')
    $.ajax
      type: 'PATCH'
      url:  "/appointments/#{appointment_id}/start_date?new_date=#{e.date}"

if !$('.completed_date_input').hasClass('hidden')
  $('#completed_date').datetimepicker(defaultDate: "<%= format_datetime(@appointment.completed_date) %>")
  $('#completed_date').on 'dp.hide', (e) ->
    appointment_id = $(this).attr('appointment_id')
    $.ajax
      type: 'PATCH'
      url:  "/appointments/#{appointment_id}/completed_date?new_date=#{e.date}"