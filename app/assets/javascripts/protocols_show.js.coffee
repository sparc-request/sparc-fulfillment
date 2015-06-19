$ ->

  if $('body.protocols-show').length > 0

    # Bootstrap Tab persistence

    current_tab = $.cookie('active-protocol-tab')
    if current_tab && current_tab.length > 0
      $(".protocol-tab > a[href='##{current_tab}']").tab('show') # show tab on load

    $('.protocol-tab > a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
      tab = String(e.target).split('#')[1]
      $.cookie('active-protocol-tab', tab, expires: 1, path: '/') # save tab to cookie

    # Study Schedule Report button

    $(document).on 'click', 'a.study_schedule_report', (event) ->
      $self = $(this)
      data  = title: $self.data('title'), protocol_id: gon.protocol_id

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
                  $self.
                    addClass('btn-success').
                    removeClass('btn-danger').
                    attr('href', "/documents/#{window.document_id}.html").
                    find('span.glyphicon').
                    addClass('glyphicon-equalizer').
                    removeClass('glyphicon-refresh spin')
                  $(document).off 'click', 'a.study_schedule_report'
                  $(document).on 'click', 'a.study_schedule_report', ->
                    $notification           = $('.notification.document-notifications')
                    documents_notifications = parseInt $notification.text()

                    if documents_notifications > 0
                      $notification.
                        empty().
                        text(documents_notifications - 1)

          get_document_state()

