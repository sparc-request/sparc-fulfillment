$("#modal_area").html("<%= escape_javascript(render(partial: 'complete_all_modal', locals: { procedure_ids: @procedure_ids})) %>")
$("#modal_place").modal 'show'

$(".selectpicker").selectpicker()
$(".modal_completed_date_field").datetimepicker(format: 'MM-DD-YYYY')



$(document).on 'click', "#complete_all_modal button.save", ->
  $(this).addClass("disabled")

  # appointment_id = ('.row.appointment').data('id')
  # data = appointment: completed_date: $('.modal_completed_date_field').data("DateTimePicker").date().toDate().toUTCString()
  # $.ajax
  #   type: 'PUT'
  #   data: data
  #   url:  "/appointments/#{appointment_id}.js"
  #   success: ->
  #     $('#completed-appointments-table').bootstrapTable('refresh', {silent: "true"})
  #     $('#start_date').data("DateTimePicker").maxDate(e.date)


