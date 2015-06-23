$ ->

  $(document).on 'load-success.bs.table', 'table.participants', ->
    $.each $('table.participants td.participant_report a'), (index, value) ->
      remote_document_generator value
