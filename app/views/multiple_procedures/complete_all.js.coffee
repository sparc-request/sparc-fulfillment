$("#modal_area").html("<%= escape_javascript(render(partial: 'complete_all_modal', locals: { procedure_ids: @procedure_ids})) %>")
$("#modal_place").modal 'show'

$(document).on 'click', "#complete_all_modal button.save", (e) ->
  if !$('.date_field').val() || !$('#complete_all_modal .performed-by-dropdown').val()
    e.preventDefault()
    $('#multiple_procedures_modal_errors').addClass('alert').addClass('alert-danger').html('Please complete the required fields:')
  else
    $(this).addClass("disabled")

$(".selectpicker").selectpicker()

$(".date_field").datetimepicker
  format: 'MM/DD/YYYY'
  ignoreReadonly: true