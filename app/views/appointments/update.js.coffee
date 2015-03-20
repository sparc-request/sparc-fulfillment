if "<%= @field %>" == "start_date"
  start_input_div = $('.start_date_input')
  if start_input_div.hasClass('hidden')
    $('.start_date_btn').addClass('hidden')
    start_input_div.removeClass('hidden')
    $('.complete_visit').removeClass('disabled')

    $('#start_date').datetimepicker(defaultDate: "<%= format_datetime(@appointment.start_date) %>")
    $('#start_date').on 'dp.hide', (e) ->
      appointment_id = $(this).attr('appointment_id')
      $.ajax
        type: 'PATCH'
        url:  "/appointments/#{appointment_id}?field=start_date&new_date=#{e.date}"
        success: ->
          if !$('.completed_date_input').hasClass('hidden')
            $('#completed_date').data("DateTimePicker").minDate(e.date)

if "<%= @field %>" == "completed_date"
  $('table#completed-appointments-table').bootstrapTable('refresh', {url: "/appointments/completed_appointments.json?participant_id=<%= @appointment.participant_id %>", silent: "true"})
  completed_input_div = $('.completed_date_input')
  if completed_input_div.hasClass('hidden')
    $('.completed_date_btn').addClass('hidden')
    completed_input_div.removeClass('hidden')

    $('#completed_date').datetimepicker(defaultDate: "<%= format_datetime(@appointment.completed_date) %>")
    $('#completed_date').data("DateTimePicker").minDate($('#start_date').data("DateTimePicker").date())
    $('#start_date').data("DateTimePicker").maxDate($('#completed_date').data("DateTimePicker").date())
    $('#completed_date').on 'dp.hide', (e) ->
      appointment_id = $(this).attr('appointment_id')
      $.ajax
        type: 'PATCH'
        url:  "/appointments/#{appointment_id}?field=completed_date&new_date=#{e.date}"
        success: ->
          $('#start_date').data("DateTimePicker").maxDate(e.date)