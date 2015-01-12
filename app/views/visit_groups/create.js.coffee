$("#visit_group_modal_errors").html("<%= escape_javascript(render(:partial =>'shared/modal_errors', locals: {errors: @errors})) %>");
if <%= @errors == nil %>
  $("#flashes_container").html("<%= escape_javascript(render(:partial =>'shared/flash_messages')) %>");
  $("#visit_modal").modal 'hide';
  change_arm(); # calling this method refreshes the dropdown to reflect the addition of a new visit
  if <%= @errors == nil and on_current_page?(@current_page, @visit_group)%>
    $("<%= @arm.id =%>").replaceWith("<%= escape_javascript(render(:partial =>'service_calendar/template', locals: {arm: @arm, page: @current_page.to_i})) %>")
  else if <%= @errors == nil %>
    $("#visits_select_for_<%= @arm.id %>").replaceWith( " <%= escape_javascript(build_visits_select(@arm, @current_page)) %>");
  else
