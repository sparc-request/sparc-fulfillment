core = $(".core[data-core-id='<%= @procedures.first.sparc_core_id %>']")

$(".completed_date_field").datetimepicker(format: 'MM-DD-YYYY')

if core.length == 0
  $(".row.calendar .col-xs-12").append("<%= escape_javascript(render partial: 'appointments/core', locals: {core_id: @procedures.first.sparc_core_id, procedures: @procedures, appointment: @appointment}) %>")
else
  core.find("tbody").append("<%= escape_javascript(render partial: 'appointments/procedure', collection: @procedures, as: :procedure) %>")

$(".selectpicker").selectpicker()

update_complete_visit_button(<%= @appointment.can_finish? %>)
