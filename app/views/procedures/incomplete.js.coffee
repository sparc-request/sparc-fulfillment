$("#modal_area").html("<%= escape_javascript(render(partial: 'incomplete', locals: { procedure: @procedure, note: @note })) %>")
$("#modal_place").modal 'show'

$(".selectpicker").selectpicker()
