$('#time_tracking_<%= @time_tracking.id %>').replaceWith("<%= j render('time_tracking_row', time_tracking: @time_tracking) %>")

$('#modalContainer').modal('hide')
