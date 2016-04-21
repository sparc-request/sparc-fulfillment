$("#modal_area").html("<%= escape_javascript(render(partial: 'complete_all_modal', locals: { procedure_ids: @procedure_ids})) %>")
$("#modal_place").modal 'show'

$(".selectpicker").selectpicker()
$(".modal_completed_date_field").datetimepicker({ format:'MM-DD-YY', defaultDate: new Date() }).val()



$(document).on 'click', "#complete_all_modal button.save", (e) ->
  if !$('.modal_completed_date_field  .datetimepicker').val() || !$('#complete_all_modal .performed-by-dropdown').val()
    e.preventDefault()
    $('#complete_modal_errors').addClass('alert').addClass('alert-danger').html('Please complete required fields')
  else
    $(this).addClass("disabled")

