$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
$('#task-list').bootstrapTable('refresh', {url: "/tasks.json", silent: "true"})
$("#modal_place").modal 'hide'