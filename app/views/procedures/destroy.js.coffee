procedure = $(".procedure[data-id='<%= @procedure.id %>']")

if procedure.siblings().length == 0
  parent = procedure.parents(".core")

  parent.remove()
else
  procedure.remove()

update_complete_visit_button(<%= @procedure.appointment.can_finish? %>)
