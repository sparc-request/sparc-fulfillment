$("#flashes_container").html("<%= escape_javascript(render(:partial =>'shared/flash_messages')) %>");
if "<%= @delete %>"
  change_arm();
  new_page = "<%= @visit_group.position %>" // "<%= Visit.per_page %>" + 1
  current_page = Number("<%= @current_page %>")
  if current_page != new_page
    $("#visits_select_for_<%= @arm.id %>").replaceWith( "<%= escape_javascript(build_visits_select(@arm, @current_page)) %>");
  else
    $(".service-calendar.arm_<%= @arm.id =%>").replaceWith("<%= escape_javascript(render(:partial =>'service_calendar/template', locals: {arm: @arm, page: @current_page.to_i})) %>");

