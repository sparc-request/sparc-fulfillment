$("#visit_group_modal_errors").html("<%= escape_javascript(render(:partial =>'shared/modal_errors', locals: {errors: @errors})) %>");
if $("#visit_group_modal_errors > .alert.alert-danger > p").length == 0
  $("#flashes_container").html("<%= escape_javascript(render(:partial =>'shared/flash_messages')) %>");
  $("#visit_modal").modal 'hide';
  change_arm(); # calling this method refreshes the dropdown to reflect the addition of a new visit
  new_page = "<%= @visit_group.position %>" // "<%= Visit.per_page %>" + 1
  current_page = Number("<%= @current_page %>")
  if current_page != new_page
    $("#visits_select_for_<%= @arm.id %>").replaceWith( "<%= escape_javascript(build_visits_select(@arm, @current_page)) %>");
  else
    $(".service-calendar.arm_<%= @arm.id =%>").replaceWith("<%= escape_javascript(render(:partial =>'service_calendar/template', locals: {arm: @arm, page: @current_page.to_i})) %>");
