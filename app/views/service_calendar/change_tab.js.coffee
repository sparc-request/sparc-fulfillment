# Overwrite the visits
<% @arms_and_pages.each do |arm_id, value| %>
  <% value[:arm].line_items.each do |line_item| %>
  $(".visits_for_line_item_<%= line_item.id %>").html("<%= escape_javascript(render partial: '/service_calendar/visits', locals: {line_item: line_item, page: value[:page], tab: @tab}) %>")
  <% end %>
<% end %>