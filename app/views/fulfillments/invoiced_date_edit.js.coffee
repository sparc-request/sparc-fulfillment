$("#modalContainer").html("<%= escape_javascript(render(:partial => 'fulfillments/invoiced_date_edit_form', locals: {line_item: @line_item, fulfillment: @fulfillment })) %>").modal('show')
$('#invoiced_date').datetimepicker
  format: "MM/DD/YYY"
  ignoreReadonly: true
  allowInputToggle: false
$(".selectpicker").selectpicker()
