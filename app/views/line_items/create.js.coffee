$("#modal_errors").html("<%= escape_javascript(render(:partial =>'shared/modal_errors', locals: {errors: @errors})) %>")
if $("#modal_errors > .alert.alert-danger > p").length == 0
  $("#flashes_container").html("<%= escape_javascript(render('flash')) %>")
  $("#modal_place").modal 'hide'
  $("#study_level_activities").html("<%= escape_javascript(render(:partial =>'protocols/study_level_activities', locals: {protocol: @line_item.protocol})) %>")