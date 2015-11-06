$ ->

  $(document).on 'load-success.bs.table', '#participants-tracker-table', ->
    tables_to_refresh = ['table.protocol_reports']
    
    $.each $('table.participants td.participant_report button'), (index, value) ->
      remote_document_generator value, tables_to_refresh

  $(document).on 'click', '.participant-calendar', ->
    protocol_id = $(this).attr('protocol_id')
    participant_id = $(this).attr('participant_id')
    window.location = "/participants/#{participant_id}"

  $(document).on 'click', '.change-arm', ->
    participant_id = $(this).attr('participant_id')
    data = arm_id : $(this).attr('arm_id')
    $.ajax
      type: 'GET'
      url: "/participants/#{participant_id}/change_arm"
      data: data

  $(document).on 'change', '.participant_status', ->
    participant_id = $(this).data("id")
    status         = $(this).val()
    data = 'participant': 'status': status
    $.ajax
      type: "PUT"
      url: "/participants/#{participant_id}"
      data: data