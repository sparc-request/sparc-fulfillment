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

            $.each tables_to_refresh, (index, value) ->
                $(value).bootstrapTable 'refresh', silent: true

            switch document_state
              when 'Completed'
                add_to_report_notification_count(data.document.documentable_type, 1)
                set_glyphicon_finished(element)
                add_dropdown_to_button(element)

                #Download Report
                $("li a[title='Download Report']").off('click').on 'click', ->
                  ul = $(this).parents('.document-dropdown-menu')
                  button = $(ul).siblings('.report-button')
                  $(ul).toggle()

                  update_view_on_download_new_report $("a.attached_file[data-id=#{button.data('document_id')}]") ,'table.protocol_reports', 'Protocol'

                #Generate New Report
                $("li a[title='Generate New Report']").off('click').on 'click', ->
                  ul = $(this).parents('.document-dropdown-menu')
                  button = $(ul).siblings('.report-button')
                  $(ul).toggle()

                  $(button).children('.caret').remove()
                  set_glyphicon_loading button

                  generate_document button, tables_to_refresh

                #Toggle Dropdown **Intentionally Not a Bootstrap Dropdown**
                $(element).off('click').on 'click', ->
                  if $(element).hasClass("btn-success")
                    ul = $(this).parents('document-dropdown-menu')
                    active = false

                    if $(ul).is(':visible')
                      active = true

                    #Toggle all other open dropdown menus
                    $("ul.document-dropdown-menu").filter("visible").toggle()

                    if active == false
                      $(ul).toggle()

              when 'Error'
                set_glyphicon_error element
              else
                setTimeout get_document_state, 1500

      get_document_state()

set_glyphicon_loading = (element) ->
  $(element).
    addClass('btn-warning').
    removeClass('btn-success').
    removeClass('btn-default').
    find('span.glyphicon').
    addClass('glyphicon-refresh spin').
    removeClass('glyphicon-equalizer')

set_glyphicon_error = (element) ->
  $(element).
    addClass('btn-danger').
    removeClass('btn-warning').
    find('span.glyphicon').
    addClass('glyphicon-alert').
    removeClass('glyphicon-refresh spin')
            
set_glyphicon_finished = (element) ->
  $(element).
    addClass('btn-success').
    removeClass('btn-warning').
    removeClass('btn-default').
    find('span.glyphicon').
    addClass('glyphicon-equalizer').
    removeClass('glyphicon-refresh spin')

add_dropdown_to_button = (element) ->
  dropdown_id_indicator = "document_menu_#{$(element).attr('id')}"
  dropdown  = $(["<ul class='dropdown-menu document-dropdown-menu' role='menu' id=#{dropdown_id_indicator}>",
                    "<li><a href='/documents/#{document_id}.html' target='blank' title='Download Report'>Download Report</a></li>"
                    "<li><a href='javascript:void(0)' title='Generate New Report'>Generate New Report</a></li>"
                  "</ul>"
                ].join(""))

  $(element).attr('data-toggle', 'dropdown')
  $(element).siblings('#'+dropdown_id_indicator).replaceWith(dropdown)

  caret = "<span class='caret'></span>"
  $(element).append(caret)
