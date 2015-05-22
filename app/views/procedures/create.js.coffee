core = $(".core[data-core-id='<%= @procedures.first.sparc_core_id %>']")

$(".completed_date_field").datetimepicker(format: 'MM-DD-YYYY')

if core.length == 0
  $(".cores > tbody").append("<%= escape_javascript(render partial: 'appointments/core', locals: {core_id: @procedures.first.sparc_core_id, procedures: @procedures}) %>")
else
  core.find("tbody").append("<%= escape_javascript(render partial: 'appointments/procedure', collection: @procedures, as: :procedure) %>")

$(".selectpicker").selectpicker()

update_complete_visit_button(<%= @procedures.first.appointment.can_finish? %>)
