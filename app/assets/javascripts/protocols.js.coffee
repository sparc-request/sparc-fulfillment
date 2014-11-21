$ ->
  if $("body.protocols-index").length > 0

    $(".bootstrap-table .fixed-table-toolbar").
      prepend('<div class="columns btn-group pull-right financial-management-view" data-toggle="buttons"><label class="btn btn-default financial" title="Financial View"><input type="radio" autocomplete="off" value="financial"><i class="glyphicon glyphicon-usd"></i></label><label class="btn btn-default management" title="Management View"><input type="radio" autocomplete="off" value="management"><i class="glyphicon glyphicon-book"></i></label></div>')

    $(".financial-management-view label").on "click", ->
      e = $(this)

    $('#events-table').on "click-row.bs.table", (e, row, $element) ->
      protocol_id = row.id
      window.location = "/protocols/#{protocol_id}"

    $('#events-table').on 'search.bs.table', (e, text) ->
      if text == ''
        status = $('.selectpicker').val()
        $('#events-table').bootstrapTable('refresh', {url: "/protocols/protocols_by_status.json?status=" + status})
      else
        $('#events-table').bootstrapTable('refresh', {url: "/protocols.json"})

    $(document).on 'change', '.selectpicker', ->
      status = $(this).val()
      $('#events-table').bootstrapTable('refresh', {url: "/protocols/protocols_by_status.json?status=" + status})