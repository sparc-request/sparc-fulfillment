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
        document_id = $(element).data("document_id")

        $.ajax
          type: 'GET'
          url: "/documents/#{document_id}.json"
          success: (data) ->
            document_state = data.document.state
            document_state = data.document.state

            $.each tables_to_refresh, (index, value) ->
                $(value).bootstrapTable 'refresh', silent: true

            if document_state != 'Completed'
              setTimeout get_document_state, 1500
            else
              add_to_report_notification_count(data.document.documentable_type, 1)

              set_glyphicon_finished element

              dropdown_id_indicator = "document_menu_#{$(element).attr('id')}"
              dropdown  = $(["<ul class='dropdown-menu document-dropdown-menu' role='menu' id=#{dropdown_id_indicator}>",
                                "<li><a href='/documents/#{document_id}.html' target='blank' title='Download Report'>Download Report</a></li>"
                                "<li><a href='javascript:void(0)' title='Generate New Report'>Generate New Report</a></li>"
                              "</ul>"
                            ].join(""))

              $(element).attr('data-toggle', 'dropdown')
              $(element).siblings('#'+dropdown_id_indicator).replaceWith(dropdown)

              $("li a[title='Download Report']").off('click').on 'click', ->
                ul = $(this).parents().eq(1)
                button = $(ul).siblings('a.dropdown-toggle')
                ul.toggle()

                document_id = button.data("document_id")

                update_view_on_download_new_report $("a.attached_file[data-id=#{document_id}]") ,'table.protocol_reports', 'Protocol'

              $("li a[title='Generate New Report']").off('click').on 'click', ->
                ul = $(this).parents().eq(1)
                button = $(ul).siblings('a.dropdown-toggle')
                ul.toggle()

                button.removeClass('btn-success')
                set_glyphicon_loading button

                generate_document button, tables_to_refresh
              
              $(element).off('click').on 'click', ->
                ul = $(this).siblings("ul.document-dropdown-menu")
                active = false

                if ul.attr("style") == "display: block;"
                  active = true

                $("ul.document-dropdown-menu[style='display: block;']").toggle()

                if active == false
                  $(this).siblings("ul.document-dropdown-menu").toggle()

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
