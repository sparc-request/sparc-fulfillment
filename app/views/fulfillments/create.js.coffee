$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>")
<% unless @errors %>
$("#flashes_container").html("<%= escape_javascript(render('flash')) %>")
$("#modal_area").html("<%= escape_javascript(render(partial: 'study_level_activities/fulfillments_table', locals: {line_item: @line_item, header_text: 'Fulfillments List'})) %>")
$("#fulfillments-table").bootstrapTable()
$('#study-level-activities-table').bootstrapTable('refresh')
<% end %>
