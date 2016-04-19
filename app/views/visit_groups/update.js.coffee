$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>");

<% if @visit_group.errors[:name].any? %>
# reset name field, if there was a validation error
$("#visit_group_<%= @visit_group.id %>").val("<%= @visit_group.reload.name %>")
<% end %>

<% unless @errors %>
$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
$("#modal_place").modal 'hide'

$(".visit_dropdown option[value=<%= @visit_group.id %>]").text("- <%= @visit_group.name %>") #update page dropdown
$(".visit_dropdown").selectpicker('refresh')
$("#visit_group_<%= @visit_group.id %>").val("<%= @visit_group.name %>") #update visit group name input
$("#visit-before-display-<%= @visit_group.id %>").html("<%= @visit_group.window_before %>")
$("#visit-after-display-<%= @visit_group.id %>").html("<%= @visit_group.window_after %>")
$("#visit-day-display-<%= @visit_group.id %>").html("<%= @visit_group.day %>")

# update dropdown to page visit groups
$("#select_for_arm_<%= @arm.id %>").html("<%= escape_javascript(render partial: '/study_schedule/visit_group_page_select', locals: {arm: @arm, page: @current_page.to_i}) %>")
$(".selectpicker").selectpicker()

<% if on_current_page?(@current_page, @visit_group.position) %>
# Overwrite the visit_groups
$(".visit_groups_for_<%= @arm.id %>").html("<%= escape_javascript(render partial: '/study_schedule/visit_groups', locals: { arm: @arm, visit_groups: @visit_groups, tab: @schedule_tab }) %>")
# Overwrite the check columns
$(".check_columns_for_arm_<%= @arm.id %>").html("<%= escape_javascript(render partial: '/study_schedule/check_visit_columns', locals: { visit_groups: @visit_groups, tab: @schedule_tab }) %>")
# Overwrite the visits
<% @arm.line_items.each do |line_item| %>
$(".visits_for_line_item_<%= line_item.id %>").html("<%= escape_javascript(render partial: '/study_schedule/visits', locals: {line_item: line_item, page: @current_page, tab: @schedule_tab}) %>")
<% end %>
<% end %>
<% end %>
