$(document).on('click', '.dashboard_link', ->
  if $(this).hasClass('active')
    $(this).removeClass('active')
    $(this).text("-- Show Dashboard --")
  else
    $(this).addClass('active')
    $(this).text("-- Hide Dashboard --")

  $('#dashboard').slideToggle()
)