$ ->
  $("#newParticipantForm").modal 'hide'
  $table.bootstrapTable "refresh",
    url: "/protocols/#{protocol.sparc_id}/show.json"