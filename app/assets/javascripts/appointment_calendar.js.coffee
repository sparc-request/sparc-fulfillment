$ ->

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

  $(document).on('focus', '.atimepicker', ->
    $(this).timepicker({disableFocus: true})
  )

  $(document).on('hide.datepicker', (e) ->
    id = $(e.target).attr('appointment_id')
    data =
      'date': $(e.target).val()
    $.ajax
      type: 'PATCH'
      url: "/appointments/#{id}/#{e.target.id}"
      data: data

    # Without this, hide.timepicker is also being called.
    # Need to leave this in for now.
    e.stopImmediatePropagation()
  )

  $(document).on('hide.timepicker', (e) ->
    id = $(e.target).attr('appointment_id')
    data =
      'hour': e.time.hours,
      'minute': e.time.minutes,
      'meridian': e.time.meridian
    $.ajax
      type: 'PATCH'
      url: "/appointments/#{id}/#{e.target.id}"
      data: data
  )

