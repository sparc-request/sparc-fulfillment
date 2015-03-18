$("#task-list").bootstrapTable('refresh')
$("#modal_place").modal 'hide'
$("#flashes_container").html("<%= escape_javascript(render('flash')) %>")
