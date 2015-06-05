<% @arms_and_pages.each do |arm_id, value| %>
$("#arms_container_<%= arm_id %>").html("<%= escape_javascript(render partial: '/service_calendar/arm', locals: {arm: value[:arm], page: value[:page].to_i, tab: @tab}) %>")
$("#visits_select_for_<%= arm_id %>").selectpicker()
<% end %>

$(".glyphicon-refresh").hide()