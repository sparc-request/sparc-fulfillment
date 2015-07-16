$("#modal_area").html("<%= escape_javascript(render(partial: 'incomplete_all_modal', locals: { core_id: @core_id, note: @note })) %>")
$("#modal_place").modal 'show'
