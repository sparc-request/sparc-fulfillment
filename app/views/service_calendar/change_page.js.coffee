# Easily accessed variables
# Prevents having to do <%= %> every time
arm_id = <%= @arm.id %>
page = <%= @page %>
visit_count = <%= @arm.visit_count %>

# Set new pages
$("#arrow-left-#{arm_id}").attr('page', page - 1)
$("#arrow-right-#{arm_id}").attr('page', page + 1)
# Disable arrows if needed
disable_left = page == 1
$("#arrow-left-#{arm_id}").attr('disabled', disable_left)
disable_right = visit_count - page * 5 < 0
$("#arrow-right-#{arm_id}").attr('disabled', disable_right)

# Overwrite the visit_groups
$(".visit_groups_for_#{arm_id}").html("<%= escape_javascript(render partial: '/service_calendar/visit_groups', locals: {arm: @arm, page: @page}) %>")

# Overwrite the visits
<% @arm.line_items.each do |line_item| %>
$(".visits_for_<%= line_item.id %>").html("<%= escape_javascript(render partial: '/service_calendar/visits', locals: {line_item: line_item, page: @page}) %>")
<% end %>
