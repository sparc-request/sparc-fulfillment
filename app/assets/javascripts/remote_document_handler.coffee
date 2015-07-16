window.remote_document_generator = (element, tables_to_refresh) ->
  $(element).off('click').one 'click', (event) ->
    generate_document element, tables_to_refresh, event

generate_document = (element, tables_to_refresh, event = null) ->
  data = $(element).data()

  if event isnt null
    event.preventDefault()

  $.ajax
    type: 'POST'
    url: '/reports.js'
    data: data
    success: ->
      set_glyphicon_loading element

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

              set_glyphicon_finished element

              dropdown_id_indicator = "document_menu_#{$(element).attr('id')}"
              dropdown  = $(["<ul class='dropdown-menu document-dropdown-menu' role='menu' id=#{dropdown_id_indicator}>",
                                "<li><a href='/documents/#{window.document_id}.html' target='blank' title='Download Report'>Download Report</a></li>"
                                "<li><a href='#' title='Generate New Report'>Generate New Report</a></li>"
                              "</ul>"
                            ].join(""))

              $(element).attr('data-toggle', 'dropdown')
              $(element).siblings('#'+dropdown_id_indicator).replaceWith(dropdown)

              $.each tables_to_refresh, (index, value) ->
                $(value).bootstrapTable 'refresh', silent: true

              $("li a[title='Download Report']").one 'click', ->
                decrement_notification data.document.documentable_type

              $("li a[title='Generate New Report']").one 'click', ->
                set_glyphicon_loading element
                $(this).attr('aria-expanded', 'false')
                $(element).removeClass('btn-success')

                generate_document element, tables_to_refresh

              $(element).on 'click', ->
                $(this).siblings('#'+dropdown_id_indicator).toggle()

      get_document_state()

set_glyphicon_loading = (element) ->
  $(element).
    addClass('btn-danger').
    removeClass('btn-default').
    find('span.glyphicon').
    addClass('glyphicon-refresh spin').
    removeClass('glyphicon-equalizer')

set_glyphicon_finished = (element) ->
  $(element).
    addClass('btn-success').
    removeClass('btn-danger').
    find('span.glyphicon').
    addClass('glyphicon-equalizer').
    removeClass('glyphicon-refresh spin')
