$ ->

  $(document).on('click', '.dashboard_link', ->
    if $(this).hasClass('active')
      $(this).removeClass('active')
      $(this).text("-- Show Dashboard --")
    else
      $(this).addClass('active')
      $(this).text("-- Hide Dashboard --")

    $('#dashboard').slideToggle()
  )

  $(document).on( 'change', '#appointment_select', (event) ->
    id = $(this).val()

    if id
      $.ajax
        type: 'GET'
        url: "/appointments/#{id}.js"
      event.stopPropagation()
    $('.btn-group').removeClass('open')
  )

  $(document).on 'click', '.add_service', ->
    id = $(this).attr('appointment_id')
    data =
      'service_id': $('#service_list').val(),
      'qty': $('#service_quantity').val(),
    $.ajax
      type: 'POST'
      url:  "/appointments/#{id}/procedures"
      data: data
