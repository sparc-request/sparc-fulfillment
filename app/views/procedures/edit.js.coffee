$("#modal_area").html("<%= escape_javascript(render(partial: 'edit', locals: { procedure: @procedure })) %>");
$(".date#<%= dom_id(@procedure) %>").datetimepicker(format: 'YYYY-MM-DD')
$("#modal_place").modal 'show'
