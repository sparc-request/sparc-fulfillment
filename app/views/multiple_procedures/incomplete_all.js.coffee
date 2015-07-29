$("#modal_area").html("<%= escape_javascript(render(partial: 'incomplete_all_modal', locals: {appointment_id: @appointment_id, core_id: @core_id, note: @note})) %>")
$("#modal_place").modal 'show'

$(".selectpicker").selectpicker()

$(document).on 'click', "#incomplete_all_modal button.save", ->
  $(this).addClass("disabled")
