$("#modalContainer").html("<%= escape_javascript(render(:partial => 'fulfillments/invoiced_date', locals: {line_item: @line_item, fulfillment: @fulfillment, fulfillment_id: @fulfillment.id, id: @fulfillment.id })) %>").modal('show')
$('#invoiced_date').datetimepicker
  format: "MM/DD/YYY"
  ignoreReadonly: true
  allowInputToggle: false
$(".selectpicker").selectpicker()
