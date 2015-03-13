$("#modal_area").html("<%= escape_javascript(render(partial: 'index', locals: { notes: @notes })) %>");
$("#modal_place").modal 'show'
