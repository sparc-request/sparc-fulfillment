$ ->
  $(document).on('change', '.complete',  ->
    procedure_id = $(this).val()
    $.ajax
      type: 'PUT'
      url: "/participant_calendar/complete_procedure?procedure_id=#{procedure_id}"
  )
