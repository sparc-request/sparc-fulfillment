$ ->

  $(document).on 'click', '.dashboard_link', ->
    if $(this).hasClass('active')
      $(this).removeClass('active')
      $(this).text("-- Show Dashboard --")
    else
      $(this).addClass('active')
      $(this).text("-- Hide Dashboard --")

    $('#dashboard').slideToggle()

  $(document).on 'change', '#appointment_select', (event) ->
    id = $(this).val()

    if id != "-1"
      $.ajax
        type: 'GET'
        url: "/appointments/#{id}.js"
    event.stopPropagation()

  $(document).on 'click', '.add_service', ->
    data =
      'appointment_id': $(this).attr('appointment_id'),
      'service_id': $('#service_list').val(),
      'qty': $('#service_quantity').val()

    $.ajax
      type: 'POST'
      url:  "/procedures.js"
      data: data

  # Procedure buttons

  $(document).on 'click', 'label.status.complete', ->
    procedure_id  = $(this).parents('.procedure').data('id')
    data          = procedure:
                      status: "complete"

    $.ajax
      type: 'PUT'
      data: data
      url: "/procedures/#{procedure_id}.js"

  $(document).on 'click', 'label.status.incomplete', ->
    procedure_id  = $(this).parents('.procedure').data('id')
    data          = partial: "incomplete", procedure:
                      status: "incomplete"

    $.ajax
      type: 'GET'
      data: data
      url: "/procedures/#{procedure_id}/edit.js"

  $(document).on 'click', 'button.followup.new', ->
    procedure_id  = $(this).parents('.procedure').data('id')

    $.ajax
      type: 'GET'
      url: "/procedures/#{procedure_id}/edit.js"

  $(document).on 'click', 'button.note.new',  ->
    procedure_id  = $(this).parents('.procedure').data('id')
    data          = note:
                      notable_id: procedure_id,
                      notable_type: 'Procedure'

    $.ajax
      type: 'GET'
      url: '/notes/new.js'
      data: data

  $(document).on 'click', 'button.notes.list',  ->
    procedure_id  = $(this).parents('.procedure').data('id')
    data          = notable: id: procedure_id, type: 'Procedure'

    $.ajax
      type: 'GET'
      url: '/notes.js'
      data: data

  $(document).on 'click', '.procedure button.delete', ->
    procedure_id = $(this).parents(".procedure").data("id")

    if confirm('Are you sure you want to remove this procedure?')
      $.ajax
        type: 'DELETE'
        url:  "/procedures/#{procedure_id}.js"
        error: ->
          alert('This procedure has already been marked as complete or incomplete and cannot be removed')
