$("#flashes_container").html("<%= escape_javascript(render('flash')) %>")
$('#task-list').bootstrapTable('refresh', {silent: "true"})
$(".notification.task-notifications").empty().append("<%= current_identity.reload.tasks_count %>")
$("#modal_place").modal 'hide'
