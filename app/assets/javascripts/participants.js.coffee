$ ->

  $('table.participants').on 'click', 'td.change_arm a', ->
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

  $(document).on 'click', '.participant-details', ->
    participant_id = $(this).attr('participant_id')
    $.ajax
      type: 'GET'
      url: "/participants/#{participant_id}/details"

  $(document).on 'click', '.participant-calendar', ->
    protocol_id = $(this).attr('protocol_id')
    participant_id = $(this).attr('participant_id')
    window.location = "/protocols/#{protocol_id}/participants/#{participant_id}"

  $(document).on 'click', '.stats', ->
    protocol_id = $(this).attr('protocol_id')
    participant_id = $(this).attr('participant_id')
    alert "Stats -> Protocol: #{protocol_id}, Participant: #{participant_id}"

  $(document).on 'change', '.recruitment_source_dropdown', ->
    id = $(this).data('id')
    option = $(this).val()
    $.ajax
      type: 'PATCH'
      url: "/participants/#{id}/set_recruitment_source?source=#{option}"

  capitalize = (string) ->
    string.charAt(0).toUpperCase() + string.slice(1).toLowerCase()

(exports ? this).refreshParticipantTables = (protocol_id, participant_id) ->
  $("#participants-list-table").bootstrapTable 'refresh', {url: "/protocols/#{protocol_id}/participants.json"}
  $("#participants-tracker-table").bootstrapTable 'refresh', {url: "/protocols/#{protocol_id}/participants.json"}
  $("#participant-info").bootstrapTable 'refresh', {url: "/protocols/#{protocol_id}/participants/#{participant_id}.json"}
