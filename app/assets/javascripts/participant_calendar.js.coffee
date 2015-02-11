$ ->
  $(document).on('change', '#status_complete',  ->
    procedure_id = $(this).val()
    $.ajax
      type: 'PUT'
      url: "/procedures/#{procedure_id}/participant_calendar/complete_procedure"
  )
