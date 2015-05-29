window.onload = (e) ->
  if typeof gon != 'undefined' and gon.appointment_id
    $("#appointment_select").selectpicker('val', "#{gon.appointment_id}")
    $("#appointment_select").selectpicker().trigger("change")
