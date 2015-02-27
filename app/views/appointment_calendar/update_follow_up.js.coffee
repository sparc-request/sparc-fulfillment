inputObject = $(".follow_up_date[value = <%= @procedure.id %>] > input")
btnObject = $(".btn.follow_up_date[value = <%= @procedure.id %>]")
if <%= @has_date %>
  inputObject.val("<%= @date %>")
  if inputObject.hasClass("hidden")
    inputObject.removeClass("hidden")
    btnObject.addClass("hidden")
else
  inputObject.val("")
  if btnObject.hasClass("hidden")
    btnObject.removeClass("hidden")
    inputObject.addClass("hidden")
$("#modal_place").modal 'hide'