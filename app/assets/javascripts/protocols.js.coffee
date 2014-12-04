$ ->
  if $("body.protocols-index").length > 0

    #Setting the default state of the index page on initial load
    $('#protocol-list').bootstrapTable('hideColumn', 'start_date')
    $('#protocol-list').bootstrapTable('hideColumn', 'end_date')
    $('#protocol-list').bootstrapTable('hideColumn', 'study_cost')
    $('#protocol-list').bootstrapTable('hideColumn', 'subsidy_amount')
    $('#protocol-list').bootstrapTable('hideColumn', 'subsidy_committed')
    $('#protocol-list').bootstrapTable('hideColumn', 'subsidy_expended')


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

    #Index table events
    $(document).on 'change', '.index_selectpicker', ->
      status = $(this).val()
      $('#protocol-list').bootstrapTable('refresh', {url: "/protocols.json?status=" + status, silent: "true"})

    $(document).on 'click', '.financial', ->
      $('#protocol-list').removeClass('custom_striped')
      $('#protocol-list').addClass('custom_striped_financial')
      $('#protocol-list').bootstrapTable('hideColumn', 'updates')
      $('#protocol-list').bootstrapTable('hideColumn', 'status')
      $('#protocol-list').bootstrapTable('hideColumn', 'short_title')
      $('#protocol-list').bootstrapTable('hideColumn', 'coordinators')
      $('#protocol-list').bootstrapTable('hideColumn', 'irb_status')
      $('#protocol-list').bootstrapTable('showColumn', 'start_date')
      $('#protocol-list').bootstrapTable('showColumn', 'end_date')
      $('#protocol-list').bootstrapTable('showColumn', 'study_cost')
      $('#protocol-list').bootstrapTable('showColumn', 'subsidy_amount')
      $('#protocol-list').bootstrapTable('showColumn', 'subsidy_committed')
      $('#protocol-list').bootstrapTable('showColumn', 'subsidy_expended')

    $(document).on 'click', '.management', ->
      $('#protocol-list').addClass('custom_striped')
      $('#protocol-list').removeClass('custom_striped_financial')
      $('#protocol-list').bootstrapTable('showColumn', 'updates')
      $('#protocol-list').bootstrapTable('showColumn', 'status')
      $('#protocol-list').bootstrapTable('showColumn', 'short_title')
      $('#protocol-list').bootstrapTable('showColumn', 'coordinators')
      $('#protocol-list').bootstrapTable('showColumn', 'irb_status')
      $('#protocol-list').bootstrapTable('hideColumn', 'start_date')
      $('#protocol-list').bootstrapTable('hideColumn', 'end_date')
      $('#protocol-list').bootstrapTable('hideColumn', 'study_cost')
      $('#protocol-list').bootstrapTable('hideColumn', 'subsidy_amount')
      $('#protocol-list').bootstrapTable('hideColumn', 'subsidy_committed')
      $('#protocol-list').bootstrapTable('hideColumn', 'subsidy_expended')

    #Faye logic
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


#Table formatting code
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

(exports ? this).cents_to_dollars = (value) ->
  cents = value / 100
  dollars = '$ ' + cents.toFixed(2)

  dollars

(exports ? this).number_to_percent = (value) ->
  value + '%'

