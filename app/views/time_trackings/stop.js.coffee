<% if @time_tracking.component_name.present? %>
$(".sidebar-span-comp[data-line-item-id='<%= @time_tracking.line_item_id %>'][data-component-name='<%= j @time_tracking.component_name %>']").html("<%= j link_to(icon('far', 'clock'), time_trackings_path(time_tracking: { protocol_id: @time_tracking.protocol_id, line_item_id: @time_tracking.line_item_id, component_name: @time_tracking.component_name }), method: :post, remote: true, class: 'text-secondary') %>")
<% else %>
$('#favorites-sidebar-span-li-<%= @time_tracking.line_item_id %>, #all-sidebar-span-li-<%= @time_tracking.line_item_id %>').html("<%= j link_to(icon('far', 'clock'), time_trackings_path(time_tracking: { protocol_id: @time_tracking.protocol_id, line_item_id: @time_tracking.line_item_id }), method: :post, remote: true, class: 'text-secondary') %>")
<% end %>

$('#timeTrackingsTable').bootstrapTable('refresh')
