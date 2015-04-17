$("#modal_area").html("<%= escape_javascript(render(partial: 'edit', locals: { procedure: @procedure })) %>")
$(".date#<%= dom_id(@procedure) %>").datetimepicker(format: 'MM-DD-YYYY')
$("#modal_place").modal 'show'
