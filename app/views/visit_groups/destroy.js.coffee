$("#flashes_container").html("<%= escape_javascript(render('application/flash')) %>")
<% if @delete %>
# update dropdown of visit groups
$("#visits_select_for_<%= @arm.id %>").html("<%= escape_javascript(visits_select_options(@arm, @current_page)) %>")
# and update associated selectpicker
$("#select_for_arm_<%= @arm.id %> > .visit_dropdown").selectpicker('refresh')

remove_visit_group("<%= @visit_group.id %>")

<% if  on_current_page?(@current_page, @visit_group) %>
  # Overwrite the visit_groups
$(".visit_groups_for_<%= @arm.id %>").html("<%= escape_javascript(render partial: '/study_schedule/visit_groups', locals: {arm: @arm, visit_groups: @visit_groups}) %>")
# Overwrite the check columns
$(".check_columns_for_arm_<%= @arm.id %>").html("<%= escape_javascript(render partial: '/study_schedule/check_visit_columns', locals: {visit_groups: @visit_groups}) %>")
# Overwrite the visits
<% @arm.line_items.each do |line_item| %>
$(".visits_for_line_item_<%= line_item.id %>").html("<%= escape_javascript(render partial: '/study_schedule/visits', locals: {line_item: line_item, page: @current_page, tab: @schedule_tab}) %>")
<% end %>
<% end %>
<% end %>
