$("#modal_area").html("<%= escape_javascript(render(partial: 'form', locals: {task: @task, clinical_providers: @clinical_providers})) %>")
$("#modal_place").modal 'show'
$("#follow_up_datepicker").datetimepicker(format: 'MM-DD-YYYY')
$(".selectpicker").selectpicker()
