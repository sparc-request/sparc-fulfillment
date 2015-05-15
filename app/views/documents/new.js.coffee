$("#modal_area").html("<%= escape_javascript(render(partial: 'new', locals: { document: @document })) %>");
$("#modal_place").modal 'show'
