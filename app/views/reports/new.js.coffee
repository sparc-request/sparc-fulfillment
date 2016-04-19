$("#modal_area").html("<%= escape_javascript(render(partial: @report_type, locals: { title: @title, report_type: @report_type })) %>")
$("#modal_place").modal('show')
$('#start_date').datetimepicker
  format: 'MM-DD-YYYY'
  ignoreReadonly: true
$('#end_date').datetimepicker
  format: 'MM-DD-YYYY'
  ignoreReadonly: true
$(".modal-content .selectpicker").selectpicker()