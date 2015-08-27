$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>");
if $("#modal_errors > .alert.alert-danger > p").length == 0
  $("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
  $("#study-level-activities-table").bootstrapTable('refresh')
  $("#fulfillments-table").bootstrapTable('refresh')
  $("#modal_place").modal 'hide'
