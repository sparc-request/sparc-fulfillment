$ ->

  $(document).on 'load-success.bs.table', 'table.participants', ->
    tables_to_refresh = ['table.protocol_reports']
    
    $.each $('table.participants td.participant_report a'), (index, value) ->
      remote_document_generator value, tables_to_refresh

  $(document).on 'change', '.participant_status', ->
    participant_id = $(this).data("id")
    status         = $(this).val()
    data = 'participant': 'status': status
    $.ajax
      type: "PUT"
      url: "/participants/#{participant_id}"
      data: data
