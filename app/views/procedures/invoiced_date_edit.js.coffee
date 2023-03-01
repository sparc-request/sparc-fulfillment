$("#modalContainer").html("<%= escape_javascript(render(:partial => 'procedures/invoiced_date_edit_form', locals: {procedure: @procedure, invoiced_date: @procedure.invoiced_date, header_text: 'Edit Procedure Invoiced Date'})) %>");
$("#modalContainer").modal 'show'
$("#invoiced_date").datetimepicker
  format: 'MM/DD/YYYY'
  ignoreReadonly: true
  allowInputToggle: false
$(".selectpicker").selectpicker()
