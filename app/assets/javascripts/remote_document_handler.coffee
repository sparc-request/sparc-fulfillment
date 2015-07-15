window.remote_document_generator = (element, tables_to_refresh) ->
  $(element).one 'click', (event) ->
    $self = $(this)
    data = $self.data()
    event.preventDefault()

    $.ajax
      type: 'POST'
      url: '/reports.js'
      data: data
      success: ->
        $self.
          addClass('btn-danger').
          removeClass('btn-default').
          find('span.glyphicon').
          addClass('glyphicon-refresh spin').
          removeClass('glyphicon-equalizer')
      complete: ->
        document_state = ''

        get_document_state = ->
          $.ajax
            type: 'GET'
            url: "/documents/#{window.document_id}.json"
            success: (data) ->
              document_state = data.document.state

              if document_state != 'Completed'
                setTimeout get_document_state, 1500
              else
                increment_notification data.document.documentable_type

                $self.
                  addClass('btn-success').
                  removeClass('btn-danger').
                  attr('href', "/documents/#{window.document_id}.html").
                  find('span.glyphicon').
                  addClass('glyphicon-equalizer').
                  removeClass('glyphicon-refresh spin')

                refresh_button = $([
                  "<button class='btn btn-xs refresh-report' title='Refresh Report' name='refresh' type='button' data-toggle='tooltip' data-animation='false'>",
                    "<span class='glyphicon glyphicon-refresh'></span>"
                ].join(""))

                refresh_button.insertAfter($(element))

                $.each tables_to_refresh, (index, value) ->
                  $(value).bootstrapTable 'refresh', silent: true

                refresh_button.one 'click', ->
                  $('table.protocol').bootstrapTable 'refresh', silent: true

                $(element).one 'click', ->
                  decrement_notification data.document.documentable_type

        get_document_state()
