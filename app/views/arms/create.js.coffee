$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>")
<% unless @errors %>
$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
$("#modal_place").modal 'hide'
create_arm("<%= @arm.name %>", "<%= @arm.id %>");
$(".study_schedule_container").append("<%= escape_javascript(render(partial: 'study_schedule/arm', locals: {arm: @arm, page: 1, tab: @schedule_tab})) %>");
$("#manage_visit_groups").empty()
$("#manage_visit_groups").html("<%= escape_javascript(render partial: '/study_schedule/study_schedule_management/visit_groups_selectpicker', locals: {protocol: @arm.protocol}) %>")
$(".selectpicker").selectpicker()

$('div.study_schedule_container [data-toggle="tooltip"]').tooltip()
$('#manage_visit_groups [data-toggle="tooltip"]').tooltip()
<% end %>
