$("#modalContainer").html("<%= j render 'time_tracking_modal', time_tracking: @time_tracking %>").modal('show')

$('#timeTrackingDatePicker').datetimepicker
  format: 'MM/DD/YYYY'
  ignoreReadonly: true
  allowInputToggle: false
