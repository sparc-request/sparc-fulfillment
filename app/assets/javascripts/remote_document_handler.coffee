# Copyright © 2011-2018 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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
                  $(button).
                    attr('aria-expanded', 'false').
                    removeAttr('data-toggle').
                    parents('div.btn-group').
                    removeClass('open')

                  set_glyphicon_default button

                  update_view_on_download_new_report $("a.attached_file[data-id=#{button.data('document_id')}]") ,'table.protocol_reports', 'Protocol'

                  remote_document_generator button, tables_to_refresh

                #Generate New Report
                $("li a[title='Generate New Report']").off('click').on 'click', ->
                  ul = $(this).parents('.document-dropdown-menu')
                  button = $(ul).siblings('.report-button')
                  
                  $(ul).toggle()

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

set_glyphicon_default = (element) ->
  $(element).
    addClass('btn-default').
    removeClass('btn-success').
    removeClass('btn-warning').
    removeClass('btn-danger')
  $(element).
    find('span.glyphicon').
    removeClass('glyphicon-refresh spin').
    addClass('glyphicon-equalizer')
  
  remove_caret element

set_glyphicon_loading = (element) ->
  $(element).
    addClass('btn-warning').
    removeClass('btn-default').
    removeClass('btn-success').
    removeClass('btn-danger')
  $(element).
    find('span.glyphicon').
    addClass('glyphicon-refresh spin').
    removeClass('glyphicon-equalizer')
  
  remove_caret element

set_glyphicon_error = (element) ->
  $(element).
    addClass('btn-danger').
    removeClass('btn-default').
    removeClass('btn-success').
    removeClass('btn-warning')
  $(element).
    find('span.glyphicon').
    addClass('glyphicon-alert').
    removeClass('glyphicon-refresh spin')

  remove_caret element

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
    removeClass('btn-default').
    removeClass('btn-warning').
    removeClass('btn-danger')
  $(element).
    find('span.glyphicon').
    addClass('glyphicon-equalizer').
    removeClass('glyphicon-refresh spin')

remove_caret = (element) ->
  $(element).
    find('span.caret').
    remove()

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
