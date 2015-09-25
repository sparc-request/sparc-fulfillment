$("#flashes_container").html("<%= escape_javascript(render('flash')) %>")
$('#task-list').bootstrapTable('refresh', {silent: "true"})
$(".notification.task-notifications").empty().append("<%= current_identity.reload.tasks_count %>")
notification_bubble = $('.notification.task-notifications')
notification_count = parseInt(notification_bubble.text())
if notification_count == 0
  notification_bubble.remove();
$("#modal_place").modal 'hide'
