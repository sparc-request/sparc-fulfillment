$("#modal_area").html("<%= escape_javascript(render(partial: 'index', locals: { documents: @documents, documentable_type: @documentable_type, documentable_id: @documentable_id})) %>")
$("#modal_place").modal 'show'
