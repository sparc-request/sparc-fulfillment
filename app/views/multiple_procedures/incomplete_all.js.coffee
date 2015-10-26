$("#modal_area").html("<%= escape_javascript(render(partial: 'incomplete_all_modal', locals: { procedure_ids: @procedure_ids, note: @note})) %>")
$("#modal_place").modal 'show'

$(".selectpicker").selectpicker()

$(document).on 'click', "#incomplete_all_modal button.save", ->
  $(this).addClass("disabled")
