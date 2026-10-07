# 1) Reset any running timer's sidebar button back to clock icon
<% @stopped_timers.each do |prev_timer| %>
  <% if prev_timer.component_name.present? %>
$(".sidebar-span-comp[data-line-item-id='<%= prev_timer.line_item_id %>'][data-component-name='<%= j prev_timer.component_name %>']").html("<%= j link_to(icon('far', 'clock'), time_trackings_path(time_tracking: { protocol_id: prev_timer.protocol_id, line_item_id: prev_timer.line_item_id, component_name: prev_timer.component_name }), method: :post, remote: true, class: 'text-secondary') %>")
  <% else %>
$('#favorites-sidebar-span-li-<%= prev_timer.line_item_id %>, #all-sidebar-span-li-<%= prev_timer.line_item_id %>').html("<%= j link_to(icon('far', 'clock'), time_trackings_path(time_tracking: { protocol_id: prev_timer.protocol_id, line_item_id: prev_timer.line_item_id }), method: :post, remote: true, class: 'text-secondary') %>")
  <% end %>
<% end %>

# 2) Flip newly started timer's button to red Stop
<% if @time_tracking.component_name.present? %>
$(".sidebar-span-comp[data-line-item-id='<%= @time_tracking.line_item_id %>'][data-component-name='<%= j @time_tracking.component_name %>']").html("<%= j link_to(icon('fas', 'stop fa-lg'), stop_time_tracking_path(@time_tracking), method: :put, remote: true, class: 'btn btn-sm btn-danger p-1', title: 'Stop') %>")
<% else %>
$('#favorites-sidebar-span-li-<%= @time_tracking.line_item_id %>, #all-sidebar-span-li-<%= @time_tracking.line_item_id %>').html("<%= j link_to(icon('fas', 'stop fa-lg'), stop_time_tracking_path(@time_tracking), method: :put, remote: true, class: 'btn btn-sm btn-danger p-1', title: 'Stop') %>")
<% end %>

$('#timeTrackingsTable').bootstrapTable('refresh')
