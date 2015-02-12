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

  $(document).on 'click', '.remove_procedure', ->
    id = $(this).attr('procedure_id')
    appointment_id = $(this).attr('appointment_id')
    if confirm("Are you sure you want to remove this procedure?")
      $.ajax
        type: 'DELETE'
        url:  "/appointments/#{appointment_id}/procedures/#{id}"
        error: ->
          alert("This procedure has already been marked as complete or incomplete and cannot be removed")
