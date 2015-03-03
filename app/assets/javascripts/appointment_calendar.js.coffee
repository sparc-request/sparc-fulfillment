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

    if id != "-1"
      $.ajax
        type: 'GET'
        url: "/appointments/#{id}.js"
    event.stopPropagation()
  )

  $(document).on 'click', '.add_service', ->
    data =
      'appointment_id': $(this).attr('appointment_id'),
      'service_id': $('#service_list').val(),
      'qty': $('#service_quantity').val()
    $.ajax
      type: 'POST'
      url:  "/procedures"
      data: data

  $(document).on 'click', '.remove_procedure', ->
    id = $(this).attr('procedure_id')
    if confirm("Are you sure you want to remove this procedure?")
      $.ajax
        type: 'DELETE'
        url:  "/procedures/#{id}"
        error: ->
          alert("This procedure has already been marked as complete or incomplete and cannot be removed")

  $(document).on('click', '.display_notes',  ->
    procedure_id = $(this).attr('value')
    $.ajax
      type: 'GET'
      url: "/procedures/#{procedure_id}/notes"
  )

  $(document).on('click', '.add_note',  ->
    procedure_id = $(this).attr('value')
    $.ajax
      type: 'GET'
      url: "/procedures/#{procedure_id}/notes/new"
  )

  $(document).on('change', '.complete',  ->
    procedure_id = $(this).val()
    $(this).attr('checked', true)
    $.ajax
      type: 'PUT'
      url: "/appointment_calendar/complete_procedure?procedure_id=#{procedure_id}"
  )

  $(document).on('change', '.incomplete',  ->
    procedure_id = $(this).val()
    selected_procedure_status = $(this).attr
    $.ajax
      type: 'GET'
      url:  "/appointment_calendar/edit_incomplete_procedure?procedure_id=#{procedure_id}"
    )

  $(document).on('click', '.close_incomplete', ->
    procedure_id = $(this).attr('value')
    procedure_status = $("#procedure_#{procedure_id}").attr("procedure-status")
    if procedure_status == "complete"
      $("#status_complete_#{procedure_id}").prop('checked', true)
    else
      $("#status_incomplete_#{procedure_id}").attr('checked', false)
  )

  $(document).on('click', '.follow_up_date',  ->
    procedure_id = $(this).attr('value')
    $.ajax
      type: 'GET'
      url: "/appointment_calendar/edit_follow_up/#{procedure_id}"
  )
