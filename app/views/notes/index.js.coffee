$("#modal_area").html("<%= escape_javascript(render(partial: 'index', locals: { notes: @notes, notable_type: @notable_type, notable_sym: @notable_sym })) %>")
$("#modal_place").modal 'show'
