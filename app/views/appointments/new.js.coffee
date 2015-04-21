$("#modal_area").html("<%= escape_javascript(render(partial: 'form', locals: {appointment: @appointment})) %>")
$("#modal_place").modal("show")
