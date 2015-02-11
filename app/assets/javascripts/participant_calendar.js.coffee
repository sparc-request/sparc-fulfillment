$ ->
  $(document).on('change', '#status_complete',  ->
    procedure_id = $("#status_complete").val()
    $.ajax
      type: 'PUT'
      url: "/procedures/#{procedure_id}/participant_calendar/complete_procedure"
  )
  $(document).on('click', '#display_notes',  ->
    procedure_id = $(this).attr('value')
    $.ajax
      type: 'GET'
      url: "/procedures/#{procedure_id}/notes"
  )
