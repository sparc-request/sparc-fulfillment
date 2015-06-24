<% @arms_and_pages.each do |arm_id, value| %>
$("#arms_container_<%= arm_id %>").html("<%= escape_javascript(render partial: '/study_schedule/arm', locals: {arm: value[:arm], page: value[:page].to_i, tab: @tab}) %>")
$("#visits_select_for_<%= arm_id %>").selectpicker()
<% end %>
<% if @tab == 'consolidated' %>
$(".study_level_activities_display").html("<%= escape_javascript(render partial: '/study_schedule/study_level_activities', locals: {protocol: @protocol}) %>")
$(".study_level_activities_display").show()
<% else %>
$(".study_level_activities_display").hide()
<% end %>

$('div.study_schedule_container [data-toggle="tooltip"]').tooltip()
