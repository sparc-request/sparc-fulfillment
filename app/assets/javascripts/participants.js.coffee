$ ->
  if $('#participant_list').length > 0
    protocol_id = $("#protocol_id").val()
    faye = new Faye.Client('http://localhost:9292/faye')
    faye.disable('websocket')
    faye.subscribe "/participants/#{protocol_id}/list", (data) ->
      $('#participants-table').bootstrapTable('refresh', {silent: "true"})

  window.operateEvents =
    "click .remove": (e, value, row, index) ->
      del = confirm "Are you sure you want to delete "+capitalize(row.first_name)+" "+capitalize(row.last_name)+" from the Participant List?"
      if del
        $.ajax
          type: 'DELETE'
          url: "/protocols/#{row.protocol_id}/participants/#{row.id}"
        $("#participants-table").bootstrapTable 'refresh', {url: "/protocols/#{row.protocol_id}/participants.json"}

    "click .edit": (e, value, row, index) ->
      $("#participantModal").modal 'show'
      $.ajax
        type: 'GET'
        url: "/protocols/#{row.protocol_id}/participants/#{row.id}/edit"

  #particpant tracker logic
  if $('#particpant_tracker').length > 0
    $(".glyphicon glyphicon-calendar").on "click", ->
       #TODO: insert link to particpant calendar

    $("glyphicon glyphicon-stats").on "click", ->
      #TODO: insert link to

#methods
  capitalize = (string) ->
    string.charAt(0).toUpperCase() + string.slice(1).toLowerCase()

(exports ? this).deleteFormatter = (value, row, index) ->
  [
    "<a class='remove' href='javascript:void(0)' title='Remove'>",
    "<i class='glyphicon glyphicon-remove' style='z-index: 100'></i>",
    "</a>"
  ].join ""

(exports ? this).editFormatter = (value, row, index) ->
  [
    "<a class='edit ml10' href='javascript:void(0)' title='Edit'>",
    "<i class='glyphicon glyphicon-edit'></i>",
    "</a>"
  ].join ""

(exports ? this).nameFormatter = (value, row, index) ->
  value.charAt(0).toUpperCase() + value.slice(1).toLowerCase()

(exports ? this).view_buttons = (value) ->
  '<i class="glyphicon glyphicon-calendar" participant_id=' + value + '></i>' + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i class="glyphicon glyphicon-stats" participant_id=' + value + '></i>'

