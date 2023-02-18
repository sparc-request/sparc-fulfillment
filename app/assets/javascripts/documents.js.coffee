# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

$ ->

  $(document).on 'click', '.report-request', ->
    $('#documents_table').one 'post-body.bs.table', () ->
      new_document_id = $('span.processing').first().data('id')
      documentInterval = setInterval((->
          getDocumentState(new_document_id, documentInterval)
          ), 5000)    

  getDocumentState = (id, interval) ->
    $.ajax
      method: 'GET'
      dataType: 'json'
      url: "/documents/#{id}.json"
      success: (data) ->
        switch data.document.state
          when 'Completed'
            clearInterval(interval)
            $('#documents_table').bootstrapTable('refresh', {silent: "true"})
            add_to_report_notification_count("Identity", 1)
          when 'Error'
            clearInterval(interval)
            $('#documents_table').bootstrapTable('refresh', {silent: "true"})

  $(document).on 'click', '.edit-document', ->
    document_id = $(this).data('document_id')
    $.ajax
      type: 'GET'
      url: "/documents/#{document_id}/edit.js"

  $(document).on 'click', 'a.remove-document', ->
    document_id = $(this).data('document_id')
    del = confirm "Are you sure you want to delete this document?"
    if del
      if $(this).parent().siblings("td.read_state").text() == "Unread"
        add_to_report_notification_count($(this).data('documentable_type'), -1)
      $.ajax
        type: 'DELETE'
        url: "/documents/#{document_id}.js"

  $(document).on 'change', "#organization_select", ->
    org_ids = $(this).val()
    if org_ids.length == 0
      # Hide protocols dropdown if an Organization has not been selected
      $('#protocol_section').closest('.form-group').addClass("d-none")
      $('#org_based_protocols').addClass('d-none')
      $('#protocol_section').empty()
      $('input[type=submit].report-request').prop('disabled', true)
      $.ajax
        type: 'GET'
        url: "reports/reset_services_dropdown"
    else
      $('#org_based_protocols').removeClass('d-none')
      $('#protocol_section').empty()
      $('#protocol_section').closest('.form-group').removeClass("d-none")
      $.ajax
        type: 'GET'
        url: "reports/update_services_protocols_dropdown"
        data: { org_ids: org_ids }

  $(document).on 'change', "#service_select", ->
    service_ids = $(this).val()
    if service_ids.length > 0
      $('#org_based_protocols').removeClass('d-none')
      $('#protocol_section').empty()
      $('#protocol_section').closest('.form-group').removeClass("d-none")
      $.ajax
        type: 'GET'
        url: "reports/update_protocols_dropdown"
        data: { service_ids: service_ids }


  $(document).on 'change', "#protocol_select", ->
    if $(this).val().length > 0
      $('input[type=submit].report-request').prop('disabled', false)
    else
      $('input[type=submit].report-request').prop('disabled', true)

  if $("body.documents-index").length > 0
    $(document).on 'click', 'a.attached_file', ->
      update_view_on_download_new_report $(this), 'table.documents', 'Identity'

(exports ? this).update_view_on_download_new_report = (element, table_to_update, documentable_type) ->
  row_index = element.parents().eq(1).attr("data-index")

  date_downloaded_element = element.parent().siblings("td.viewed_at")

  if date_downloaded_element.text().length == 0
    add_to_report_notification_count(documentable_type, -1)

    $(table_to_update).bootstrapTable 'updateCell', 
      index: row_index
      field: 'read_state'
      value: "Read"

(exports ? this).refreshDocumentsTables = ->
  $('#documents_table').bootstrapTable('refresh', {silent: "true"})
  $('#reports_table').bootstrapTable('refresh', {silent: "true"})
