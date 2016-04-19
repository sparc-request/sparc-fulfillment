$("#modal_area").html("<%= escape_javascript(render(partial: 'incomplete_all_modal', locals: { procedure_ids: @procedure_ids, note: @note})) %>")
$("#modal_place").modal 'show'

$(".selectpicker").selectpicker()
$(".modal_incompleted_date_field").datetimepicker(format: 'MM-DD-YYYY')



$(document).on 'click', "#incomplete_all_modal button.save", ->
  $(this).addClass("disabled")
