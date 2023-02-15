$("#modalContainer").html("<%= escape_javascript(render(:partial => 'study_level_activities/invoiced_date_edit_form', locals: {line_item: @line_item, fulfillment: @fulfillment, invoiced_date: @fulfillment.invoiced_date, header_text: 'Edit Fulfillment Invoiced Date'})) %>");
$("#modalContainer").modal 'show'
$("#invoiced_date").datetimepicker
  format: 'MM/DD/YYYY'
  ignoreReadonly: true
  allowInputToggle: false
$(".selectpicker").selectpicker()
