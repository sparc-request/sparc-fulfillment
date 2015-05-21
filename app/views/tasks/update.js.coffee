$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
$('#task-list').bootstrapTable('refresh', {url: "/tasks.json", silent: "true"})
$(".notification.task-notifications").empty().append("<%= current_identity.reload.tasks_count %>")
$("#modal_place").modal 'hide'
