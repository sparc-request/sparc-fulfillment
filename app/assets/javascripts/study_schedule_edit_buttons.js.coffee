$ ->
  #Faye logic
  faye = new Faye.Client('http://localhost:9292/faye')
  faye.disable('websocket')
  faye.subscribe '/protocols/list', (data) ->
    status = $('.selectpicker').val()
    $('#protocol-list').bootstrapTable('refresh', {url: "/protocols.json?status=" + status, silent: "true"})

  if $("body.protocols-show").length > 0
    # initialize visit group select list
    change_arm()

    $(document).on 'change', '#arms', ->
      change_arm()


    $(document).on 'click', '#remove_visit_button', ->
      visit_group_id = $("#visits").val()
      protocol_id = $('#arms').data('protocol_id')
      arm_id = $("#arms").val()
      page = $("#visits_select_for_#{arm_id}").val()

      del = confirm "Are you sure you want to delete the selected visit from all particpants?"
      if del
        $.ajax
          type: 'DELETE'
          url: "/protocols/#{protocol_id}/arms/#{arm_id}/visit_groups/#{visit_group_id}.js?page=#{page}"

    $(document).on 'click', '#remove_arm_button', ->
      protocol_id = $('#arms').data('protocol_id')
      arm_id = $("#arms").val()
      del = confirm "Are you sure you want to delete the selected arm from this protocol"
      if del
        $.ajax
          type: 'DELETE'
          url: "/protocols/#{protocol_id}/arms/#{arm_id}"


    $(document).on 'click', '#add_visit_button', ->
      protocol_id = $('#arms').data('protocol_id')
      arm_id = $('#arms').val()
      page = $("#visits_select_for_#{arm_id}").val()
      $.get "/protocols/#{protocol_id}/arms/#{arm_id}/visit_groups/new?page=#{page}"

    $(document).on 'click', '#add_service_button', ->
      protocol_id = $('#arms').data('protocol_id')
      service_id = $('#services').val()
      $.ajax
        type: 'GET'
        url: "/multiple_line_items/#{protocol_id}/#{service_id}/new"

    $(document).on 'click', '#remove_service_button', ->
      protocol_id = $('#arms').data('protocol_id')
      service_id = $('#services').val()
      $.ajax
        type: 'GET'
        url: "/multiple_line_items/#{protocol_id}/#{service_id}/edit"

(exports ? this).create_arm = (name, id) ->
  $select = $('#arms')
  $select.append('<option value=' + id + '>' + name + '</option>')
  $select.selectpicker('refresh')

(exports ? this).change_arm = ->
  $select = $('#visits')
  protocol_id = $('#arms').data('protocol_id')
  arm_id = $('#arms').val()

  $.get "/protocols/#{protocol_id}/arms/#{arm_id}/change", (data) ->
    visit_groups = data
    $select.find('option').remove()

    $.each visit_groups, (key, visit_group) ->
      $select.append('<option value=' + visit_group.id + '>' + visit_group.name + '</option>')

    $select.selectpicker('refresh')

(exports ? this).remove_arm = (arm_id) ->
  $select = $('#arms')
  $select.find("[value=#{arm_id}]").remove()
  $select.selectpicker('refresh')
