$("#modal_errors").html("<%= escape_javascript(render(:partial =>'shared/modal_errors', locals: {errors: @errors})) %>");
if $("#modal_errors > .alert.alert-danger > p").length == 0
  $(".line_item[data-id=<%= @line_item.id %>]").replaceWith("<%= escape_javascript(render(:partial =>'study_level_activities/one_time_fee', locals: {line_item: @line_item})) %>")
  $("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
  $("#modal_place").modal 'hide'