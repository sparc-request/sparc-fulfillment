$ ->
  if $('#participant_list').length > 0
    protocol_id = $("#protocol_id").val()
    faye = new Faye.Client('http://localhost:9292/faye')
    faye.disable('websocket')
    faye.subscribe "/participants/#{protocol_id}/list", (data) ->
      $('#participants-table').bootstrapTable('refresh', {silent: "true"})

  $('#participants-table').on "click-row.bs.table", (e, row, $element) ->
    for key of row
      id = "#participant_"+key
      $(id).val row[key]
    $("#participantModal").modal 'show'

  $("#new_participant_button").bind 'click', (event) ->
    $("input[id^='participant_']").val '' #clear form