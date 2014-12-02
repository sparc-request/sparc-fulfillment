$ ->
  if $("body.protocols-index").length > 0

    status = $('.index_selectpicker').val()
    $('#protocol-list').bootstrapTable('refresh', {url: "/protocols.json?status=" + status, silent: "true"})

    $(".bootstrap-table .fixed-table-toolbar").
      prepend('<div class="columns btn-group pull-right financial-management-view" data-toggle="buttons"><label class="btn btn-default financial" title="Financial View"><input type="radio" autocomplete="off" value="financial"><i class="glyphicon glyphicon-usd"></i></label><label class="btn btn-default management" title="Management View"><input type="radio" autocomplete="off" value="management"><i class="glyphicon glyphicon-book"></i></label></div>')

    $(".financial-management-view label").on "click", ->
      e = $(this)

    $('#protocol-list').on "click-row.bs.table", (e, row, $element) ->
      protocol_id = row.sparc_id
      window.location = "/protocols/#{protocol_id}"


    # if $("body.particpanttracker-particpant_tracker").length >= 0
      #insert edit excel spreadsheet and delete buttons here


    # $('#protocol-list').on 'search.bs.table', (e, text) ->
    #   if text == ''
    #     status = $('.selectpicker').val()
    #     $('#protocol-list').bootstrapTable('refresh', {url: "/protocols/protocols_by_status.json?status=" + status})
    #   else
    #     $('#protocol-list').bootstrapTable('refresh', {url: "/protocols.json"})

    $(document).on 'change', '.index_selectpicker', ->
      status = $(this).val()
      $('#protocol-list').bootstrapTable('refresh', {url: "/protocols.json?status=" + status, silent: "true"})

    faye = new Faye.Client('http://localhost:9292/faye')
    faye.disable('websocket')
    faye.subscribe '/protocols/list', (data) ->
      status = $('.selectpicker').val()
      $('#protocol-list').bootstrapTable('refresh', {url: "/protocols.json?status=" + status, silent: "true"})

  if $("body.protocols-index").length <= 0
    # initialize visit group select list
    change_arm()

    $(document).on 'change', '#arms', ->
      change_arm()


  $(".glyphicon glyphicon-calendar").on "click", ->
     #TODO: insert link to particpant calendar

  $("glyphicon glyphicon-stats").on "click", ->
    #TODO: insert link to

(exports ? this).display_date = (value) ->
  d = new Date(value)
  d.toLocaleFormat('%m/%d/%Y')


(exports ? this).change_arm = ->
  $select = $('#visits')
  arm_id = $('#arms').val()

  $.get "/protocols/arms/#{arm_id}/change", (data) ->
    visit_groups = data
    $select.find('option').remove()

    $.each visit_groups, (key, visit_group) ->
      $select.append('<option value=' + visit_group.id + '>' + visit_group.name + '</option>')

    $select.selectpicker('refresh')

(exports ? this).view_buttons = (value) ->
  '<i class="glyphicon glyphicon-calendar" participant_id=' + value + '></i>' + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i class="glyphicon glyphicon-stats" participant_id=' + value + '></i>'

