$ ->
  if $('#participant_list').length > 0
    protocol_id = $("#protocol_id").val()
    faye = new Faye.Client('http://localhost:9292/faye')
    faye.disable('websocket')
    faye.subscribe "/participants/#{protocol_id}/list", (data) ->
      $('#participants-table').bootstrapTable('refresh', {silent: "true"})

  $(document).on 'click', '#changeParticipantArm', ->
    protocol_id = $(this).attr('protocol_id')
    participant_id = $(this).attr('participant_id')
    arm_id = $(this).attr('arm_id')
    $.ajax
      type: 'GET'
      url: "/protocols/#{protocol_id}/participants/#{participant_id}/change_arm?arm_id=#{arm_id}"

  $(document).on 'click', '.remove-participant', ->
    protocol_id = $(this).attr('protocol_id')
    participant_id = $(this).attr('participant_id')
    name = $(this).attr('participant_name')
    del = confirm "Are you sure you want to delete #{name} from the Participant List?"
    if del
      $.ajax
        type: 'DELETE'
        url: "/protocols/#{protocol_id}/participants/#{participant_id}"

  $(document).on 'click', '.edit-participant', ->
    protocol_id = $(this).attr('protocol_id')
    participant_id = $(this).attr('participant_id')
    $.ajax
      type: 'GET'
      url: "/protocols/#{protocol_id}/participants/#{participant_id}/edit"

  $(document).on 'click', '.calendar', ->
    protocol_id = $(this).attr('protocol_id')
    participant_id = $(this).attr('participant_id')
    window.location = "/protocols/#{protocol_id}/participants/#{participant_id}"

  $(document).on 'click', '.stats', ->
    protocol_id = $(this).attr('protocol_id')
    participant_id = $(this).attr('participant_id')
    alert "Stats -> Protocol: #{protocol_id}, Participant: #{participant_id}"

  capitalize = (string) ->
    string.charAt(0).toUpperCase() + string.slice(1).toLowerCase()

(exports ? this).deleteFormatter = (value, row, index) ->
  [
    "<a class='remove remove-participant' href='#' title='Remove' protocol_id='#{row.protocol_id}' participant_id='#{row.id}' participant_name='#{row.last_name}'>",
    "<i class='glyphicon glyphicon-remove'></i>",
    "</a>"
  ].join ""

(exports ? this).editFormatter = (value, row, index) ->
  [
    "<a class='edit edit-participant ml10' href='#' title='Edit' protocol_id='#{row.protocol_id}' participant_id='#{row.id}'>",
    "<i class='glyphicon glyphicon-edit'></i>",
    "</a>"
  ].join ""

(exports ? this).changeArmFormatter = (value, row, index) ->
  [
    "<a class='edit change-arm ml10' href='#' title='Change Arm' id='changeParticipantArm' protocol_id='#{row.protocol_id}' participant_id='#{row.id}' arm_id='#{row.arm_id}'>",
    "<i class='glyphicon glyphicon-random'></i>",
    "</a>"
  ].join ""

(exports ? this).nameFormatter = (value, row, index) ->
  value.charAt(0).toUpperCase() + value.slice(1).toLowerCase()

(exports ? this).view_buttons = (value) ->
  '<i class="glyphicon glyphicon-calendar" participant_id=' + value + '></i>' + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i class="glyphicon glyphicon-stats" participant_id=' + value + '></i>'

(exports ? this).calendarFormatter = (value, row, index) ->
  [
    "<a class='calendar' href='#' title='Calendar' protocol_id='#{row.protocol_id}' participant_id='#{row.id}'>",
    "<i class='glyphicon glyphicon-calendar'></i>",
    "</a>"
  ].join ""

(exports ? this).statsFormatter = (value, row, index) ->
  [
    "<a class='stats' href='#' title='Stats' protocol_id='#{row.protocol_id}' participant_id='#{row.id}'>",
    "<i class='glyphicon glyphicon-stats'></i>",
    "</a>"
  ].join ""

(exports ? this).refreshParticipantTables = (protocol_id) ->
  $("#participants-list-table").bootstrapTable 'refresh', {url: "/protocols/#{protocol_id}/participants.json"}
  $("#participants-tracker-table").bootstrapTable 'refresh', {url: "/protocols/#{protocol_id}/participants.json"}
