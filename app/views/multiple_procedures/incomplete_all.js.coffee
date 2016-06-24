$("#modal_area").html("<%= escape_javascript(render(partial: 'incomplete_all_modal', locals: { procedure_ids: @procedure_ids, note: @note})) %>")
$("#modal_place").modal 'show'

$(document).on 'click', "#incomplete_all_modal button.save", (e) ->
  if !$('#incomplete_all_modal .performed-by-dropdown').val() || $('.reason-select .selectpicker .selected').index() == 0
    e.preventDefault()
    $('#multiple_procedures_modal_errors').addClass('alert').addClass('alert-danger').html('Please complete the required fields:')
  else
    $(this).addClass("disabled")

$(".selectpicker").selectpicker()

$(".modal_date_field").datetimepicker
  defaultDate: date
  ignoreReadonly: true

