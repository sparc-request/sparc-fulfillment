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