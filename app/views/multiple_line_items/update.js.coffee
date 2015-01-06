$("#line_item_modal").modal 'hide'
$("#flashes_container").html("<%= escape_javascript(render(:partial =>'shared/flash_messages')) %>");

