$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>")
if $("#modal_errors > .alert.alert-danger > p").length == 0
  $("#flashes_container").html("<%= escape_javascript(render('flash')) %>")
  $(".row.add_one_time_fee_line_item").last().before("<%= escape_javascript(render(:partial =>'study_level_activities/study_level_activity', locals: {line_item: @line_item})) %>")
  $(".selectpicker").selectpicker()
  $("#modal_place").modal 'hide'
