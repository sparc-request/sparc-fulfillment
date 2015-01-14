$("#flashes_container").html("<%= escape_javascript(render(:partial =>'shared/flash_messages')) %>");
if "<%= @delete %>"
  change_arm();
  if <%= on_current_page?(@current_page, @visit_group) %>
    $(".service-calendar.arm_<%= @arm.id =%>").replaceWith("<%= escape_javascript(render(:partial =>'service_calendar/template', locals: {arm: @arm, page: @current_page.to_i})) %>");
  else
    $("#visits_select_for_<%= @arm.id %>").replaceWith( "<%= escape_javascript(build_visits_select(@arm, @current_page)) %>");

