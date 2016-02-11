$("#modal_area").html("<%= escape_javascript(render(partial: 'form', locals: {appointment: @appointment, note: @note})) %>")
$("#modal_place").modal("show")
$(".selectpicker").selectpicker()
