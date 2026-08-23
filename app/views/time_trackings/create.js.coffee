$('#emptyTimeTrackingsRow').remove()

$('#timeTrackingsTableBody').prepend("<%= j render('time_tracking_row', time_tracking: @time_tracking) %>")

<% if @time_tracking.component_id.present? %>
$('#sidebar-span-comp-<%= @time_tracking.component_id %>').html("<%= j link_to('Stop', stop_time_tracking_path(@time_tracking), method: :put, remote: true, class: 'btn btn-sm btn-danger py-0 px-2') %>")
<% else %>
$('#sidebar-span-li-<%= @time_tracking.line_item_id %>').html("<%= j link_to('Stop', stop_time_tracking_path(@time_tracking), method: :put, remote: true, class: 'btn btn-sm btn-danger py-0 px-2') %>")
<% end %>
