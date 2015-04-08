$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
$('#task-list').bootstrapTable('refresh', {url: "/tasks.json", silent: "true"})
$(".notification.tasks").empty().append("<%= current_user.reload.tasks_count %>")
$("#modal_place").modal 'hide'