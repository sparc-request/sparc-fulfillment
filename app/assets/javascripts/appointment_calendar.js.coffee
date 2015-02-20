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

  $(document).on('change', '.complete',  ->
    procedure_id = $(this).val()
    $.ajax
      type: 'PUT'
      url: "/appointment_calendar/complete_procedure?procedure_id=#{procedure_id}"
  )

  $(document).on('change', '.incomplete',  ->
    procedure_id = $(this).val()
    $.ajax
      type: 'GET'
      url:  "/appointment_calendar/new_incomplete_procedure?procedure_id=#{procedure_id}"
    )
  $(document).on('click', '#close_incomplete', ->
    procedure_id = $(this).attr('value')
    $("#status_incomplete_#{procedure_id}").attr('checked',false)
    )


