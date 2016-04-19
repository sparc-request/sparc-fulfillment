$("#modal_area").html("<%= escape_javascript(render(partial: 'incomplete_all_modal', locals: { procedure_ids: @procedure_ids, note: @note})) %>")
$("#modal_place").modal 'show'

$(".selectpicker").selectpicker()
$(".modal_completed_date_field").datetimepicker(format: 'MM-DD-YYYY')



$(document).on 'click', "#incomplete_all_modal button.save", ->
  $(this).addClass("disabled")
  
  # $('#completed_date').datetimepicker(defaultDate: date)
  # $('#start_date').data("DateTimePicker").maxDate($('#completed_date').data("DateTimePicker").date())
  # $('#completed_date').data("DateTimePicker").minDate($('#start_date').data("DateTimePicker").date())
  # $('#completed_date').on 'dp.hide', (e) ->
  #   appointment_id = $(this).parents('.row.appointment').data('id')
  #   data = appointment: completed_date: $('.modal_completed_date_field').data("DateTimePicker").date().toDate().toUTCString()
  #   $.ajax
  #     type: 'PUT'
  #     data: data
  #     url:  "/appointments/#{appointment_id}.js"
  #     success: ->
  #       $('#completed-appointments-table').bootstrapTable('refresh', {silent: "true"})
  #       $('#start_date').data("DateTimePicker").maxDate(e.date)
