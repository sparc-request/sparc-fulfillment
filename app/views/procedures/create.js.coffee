core = $(".core[data-core-id='<%= @procedures.first.sparc_core_id %>']")

if core.length == 0
  $(".cores > tbody").append("<%= escape_javascript(render partial: 'appointments/core', locals: {core_id: @procedures.first.sparc_core_id, procedures: @procedures}) %>")
else
  core.find("tbody").append("<%= escape_javascript(render partial: 'appointments/procedure', collection: @procedures, as: :procedure) %>")
