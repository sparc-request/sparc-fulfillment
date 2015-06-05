$("#modal_errors").html("<%= escape_javascript(render(:partial =>'shared/modal_errors', locals: {errors: @errors})) %>")
<% unless @errors %>
$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
$("#modal_place").modal 'hide'
create_arm("<%= @arm.name %>", "<%= @arm.id %>");
$(".service_calendar_container").append("<%= escape_javascript(render(:partial =>'service_calendar/arm', locals: {arm: @arm, page: 1, tab: @calendar_tab})) %>");
$("#manage_visit_groups").empty()
$("#manage_visit_groups").html("<%= escape_javascript(render partial: '/service_calendar/calendar_management/visit_groups_selectpicker', locals: {protocol: @arm.protocol}) %>")
$(".selectpicker").selectpicker()
<% end %>
