$(".appointment").html("<%= escape_javascript(render(partial: 'calendar', locals: {appointment: @appointment})) %>")

if !$('.start_date_input').hasClass('hidden')
  $('#start_date').datetimepicker(defaultDate: "<%= format_datetime(@appointment.start_date) %>")
  $('#start_date').on 'dp.hide', (e) ->
    appointment_id = $(this).attr('appointment_id')
    $.ajax
      type: 'PATCH'
      url:  "/appointments/#{appointment_id}?field=start_date&new_date=#{e.date}"
      success: ->
        if !$('.completed_date_input').hasClass('hidden')
          $('#completed_date').data("DateTimePicker").minDate(e.date)

if !$('.completed_date_input').hasClass('hidden')
  $('#completed_date').datetimepicker(defaultDate: "<%= format_datetime(@appointment.completed_date) %>")
  $('#start_date').data("DateTimePicker").maxDate($('#completed_date').data("DateTimePicker").date())
  $('#completed_date').data("DateTimePicker").minDate($('#start_date').data("DateTimePicker").date())
  $('#completed_date').on 'dp.hide', (e) ->
    appointment_id = $(this).attr('appointment_id')
    $.ajax
      type: 'PATCH'
      url:  "/appointments/#{appointment_id}?field=completed_date&new_date=#{e.date}"
      success: ->
        $('#start_date').data("DateTimePicker").maxDate(e.date)

<% @appointment.procedures.each do |procedure| %>
$(".date#<%= dom_id(procedure) %>").datetimepicker(format: 'YYYY-MM-DD', defaultDate: "<%= format_date(procedure.follow_up_date) %>")
<% end %>