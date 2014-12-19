$("#flashes_container").html("<%= escape_javascript(render(:partial =>'shared/flash_messages')) %>");
if $("#line_item_modal_errors > .alert.alert-danger > p").length == 0
  $("#flashes_container").html("<%= escape_javascript(render(:partial =>'shared/flash_messages')) %>");
  $("#line_item_modal").modal 'hide'
