$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>")
<% unless @errors %>
$("#flashContainer").html("<%= escape_javascript(render('flash')) %>")
$("#modalContainer").html("<%= escape_javascript(render(partial: 'study_level_activities/fulfillments_table', locals: {line_item: @line_item, header_text: 'Fulfillments List'})) %>")
$("#fulfillments-table").bootstrapTable()
$('#studyLevelActivities').bootstrapTable('refresh')

$('#fulfillments-table').on 'load-success.bs.table', () ->
  $('input.invoice_toggle').bootstrapToggle()
  $('input.credit_toggle').bootstrapToggle()
<% end %>
