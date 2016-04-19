$("#modal_area").html("<%= escape_javascript(render(partial: 'complete_all_modal', locals: { procedure_ids: @procedure_ids})) %>")
$("#modal_place").modal 'show'

$(".selectpicker").selectpicker()
$(".modal_completed_date_field").datetimepicker(format: 'MM-DD-YYYY')



$(document).on 'click', "#complete_all_modal button.save", ->
  $(this).addClass("disabled")


