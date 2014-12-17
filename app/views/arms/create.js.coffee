$("#arm_modal_errors").html("<%= escape_javascript(render(:partial =>'shared/modal_errors', locals: {errors: @errors})) %>");

if $("#arm_modal_errors > .alert.alert-danger > p").length == 0
  $("#flashes_container").html("<%= escape_javascript(render(:partial =>'shared/flash_messages')) %>");
  $("#arm_modal").modal 'hide'
  create_arm("<%= @arm.name %>", "<%= @arm.id %>");
