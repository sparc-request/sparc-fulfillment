$("#visit_group_modal_errors").html("<%= escape_javascript(render(:partial =>'shared/modal_errors', locals: {errors: @errors})) %>");

if $("#visit_group_modal_errors > .alert.alert-danger > p").length == 0
  $("#flashes_container").html("<%= escape_javascript(render(:partial =>'shared/flash_messages')) %>");
  $("#visit_modal").modal 'hide'
  change_arm(); # calling this method refreshes the dropdown to reflect the addition of a new visit

