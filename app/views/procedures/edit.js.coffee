$("#modal_area").html("<%= escape_javascript(render(partial: 'edit', locals: { procedure: @procedure, task: @task, clinical_providers: @clinical_providers})) %>")
$("#follow_up_procedure_datepicker").datetimepicker
  format: 'MM/DD/YYYY'
  ignoreReadonly: true
$("#modal_place").modal 'show'

$(".selectpicker").selectpicker()
