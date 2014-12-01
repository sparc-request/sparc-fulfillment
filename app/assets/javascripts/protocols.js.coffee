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

  # if $("body.protocols-index").length <= 0
  #   $(document).on 'change', '#arms', ->
  #     sparc_id = $('#arms').data('id')
  #     # console.log($('#arms').val())
  #     data =
  #       'id': sparc_id
  #       'arm_id': $('#arms').val()
  #     $.ajax
  #       type: 'GET'
  #       url:  "/protocols/#{sparc_id}/change_arm"
  #       data:  data

(exports ? this).display_date = (value) ->
  d = new Date(value)
  d.toLocaleFormat('%m/%d/%Y')