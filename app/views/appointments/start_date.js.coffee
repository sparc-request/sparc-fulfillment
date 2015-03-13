start_input_div = $('.start_date_input')
start_btn_div = $('.start_date_btn')
if start_input_div.hasClass('hidden')
  start_btn_div.addClass('hidden')
  start_input_div.removeClass('hidden')
  $('#start_date').datetimepicker(defaultDate: "<%= format_datetime(@appointment.start_date) %>")
  $('#start_date').on 'dp.hide', (e) ->
    if !$('.completed_date_input').hasClass('hidden')
      $('#completed_date').data("DateTimePicker").minDate(e.date)
    appointment_id = $(this).attr('appointment_id')
    $.ajax
      type: 'PATCH'
      url:  "/appointments/#{appointment_id}/start_date?new_date=#{e.date}"

complete_btn = $('.complete_visit')
if complete_btn.hasClass('disabled')
  complete_btn.removeClass('disabled')