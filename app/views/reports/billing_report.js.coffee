$("#modal_errors").html("<%= escape_javascript(render(:partial =>'shared/modal_errors', locals: {errors: @report.errors})) %>");
if $("#modal_errors > .alert.alert-danger > p").length == 0
  $("#modal_place").modal('hide');
  $('#reports-list').bootstrapTable('refresh')
