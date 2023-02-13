$("#modalContainer").html("<%= escape_javascript(render(:partial => 'fulfillments/invoiced_date_edit_form', locals: {line_item: @line_item, fulfillment: @fulfillment })) %>");
$("#modalContainer").modal('show')
$('#invoiced_date').datetimepicker
  format: "MM/DD/YYYY"
  ignoreReadonly: true
  allowInputToggle: false
$(".selectpicker").selectpicker()
