procedure = $(".row.procedure[data-id='<%= @procedure.id %>']")

if procedure.siblings().length == 0
  parent = procedure.parents(".row.core")

  parent.remove()
else
  procedure.remove()
