core = $(".row.core[data-core-id='#{@core_id}']")

if core.length == 0
  $(".calendar").append("<%= escape_javascript(render partial: 'appointments/core', locals: {core_id: @core_id, procedures: @procedures}) %>")
else
  core.append("<%= escape_javascript(render partial: 'appointments/procedure', collection: @procedures, as: :procedure) %>")
