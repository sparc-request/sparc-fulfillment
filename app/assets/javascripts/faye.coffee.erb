$ ->
  unless <%= Rails.env.test? %>
    host    = "<%= ENV.fetch('CWF_FAYE_HOST') %>"
    scheme  = "<%= ENV.fetch('GLOBAL_SCHEME') %>"
    faye    = new Faye.Client("#{scheme}://#{host}/faye")

    faye.disable('websocket')

    if $("body.protocols-index").length > 0
      faye.subscribe '/protocols', (data) ->
        status = $('.selectpicker').val()

        $('table.protocols').bootstrapTable('refresh', {url: "/protocols.json?status=#{status}", silent: "true"})

    if $('body.protocols-show').length > 0
      faye.subscribe "/protocol_#{gon.protocol_id}", (data) ->
        $('table.protocol').bootstrapTable('refresh', {silent: "true"})
        $('table.participants').bootstrapTable('refresh', {silent: "true"})

    if $('body.documents-index').length > 0
      faye.subscribe "/documents", (data) ->
        $('table.documents').bootstrapTable('refresh', {silent: "true"})
