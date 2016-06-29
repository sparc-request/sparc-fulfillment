$("#modal_area").html("<%= escape_javascript(render(:partial =>'task_reschedule_modal', locals: {task: @task})) %>")
$("#reschedule_datepicker").datetimepicker
  format: 'MM/DD/YYYY'
  ignoreReadonly: true
$("#modal_place").modal 'show'

$(".selectpicker").selectpicker()
