$ ->

  $(document).on 'load-success.bs.table', 'table.participants', ->
    tables_to_refresh = ['table.protocol_reports']
    
    $.each $('table.participants td.participant_report a'), (index, value) ->
      remote_document_generator value, tables_to_refresh
