$("#modalContainer").html("<%= escape_javascript(render(:partial =>'study_level_activities/invoiced_date_form', locals: {line_item: @line_item, fulfillment: @fulfillment, clinical_providers: @clinical_providers, fulfillment_id: @fulfillment.id, header_text: 'Edit Invoiced Date'})) %>");
$("#modalContainer").modal 'show'
$("#invoiced_date").datetimepicker
  format: 'MM/DD/YYYY'
  ignoreReadonly: true
  allowInputToggle: false
$(".selectpicker").selectpicker()

