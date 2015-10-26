$ ->

  #this method is used on all the datepickers in the application
  $(document).on 'dp.hide', '.datetimepicker', ->
    $(this).blur()

  $('table.participants').on 'click', 'td.change_arm a', ->
    participant_id = $(this).attr('participant_id')
    arm_id = $(this).attr('arm_id')
    $.ajax
      type: 'GET'
      url: "/participants/#{participant_id}/change_arm?arm_id=#{arm_id}"

  $(document).on 'click', '.new-participant', ->
    data =
      'protocol_id' : $(this).data('protocol-id')

    $.ajax
      type: 'GET'
      url: "/participants/new.js"
      data: data

  $(document).on 'click', '.remove-participant', ->
    participant_id = $(this).attr('participant_id')
    name = $(this).attr('participant_name')
    del = confirm "Are you sure you want to delete #{name} from the Participant List?"
    if del
      $.ajax
        type: 'DELETE'
        url: "/participants/#{participant_id}"

  $(document).on 'click', '.edit-participant', ->
    participant_id = $(this).attr('participant_id')
    $.ajax
      type: 'GET'
      url: "/participants/#{participant_id}/edit"

  $(document).on 'click', '.participant-details', ->
    participant_id = $(this).attr('participant_id')
    $.ajax
      type: 'GET'
      url: "/participants/#{participant_id}/details"

  $(document).on 'click', '.participant-calendar', ->
    protocol_id = $(this).attr('protocol_id')
    participant_id = $(this).attr('participant_id')
    window.location = "/participants/#{participant_id}"

  $(document).on 'change', '.recruitment_source_dropdown', ->
    id = $(this).data('id')
    option = $(this).val()
    $.ajax
      type: 'PUT'
      url: "/participants/#{id}/set_recruitment_source?source=#{option}"

  capitalize = (string) ->
    string.charAt(0).toUpperCase() + string.slice(1).toLowerCase()

(exports ? this).refreshParticipantTables = ->
  $("#participants-list-table").bootstrapTable 'refresh', {silent: true}
  $("#participants-tracker-table").bootstrapTable 'refresh', {silent: true}
  $("#participant-info").bootstrapTable 'refresh', {silent: true}

(exports ? this).visitSorter = (a, b) ->
  format = (string) -> parseInt string.split('/').reverse().join('')

  if format(a) > format(b) then -1 else 1
