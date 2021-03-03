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

  setDocumentTableInterval = null

  $(document).on 'click', '.report-request', ->
    setDocumentTableInterval = setInterval refreshDocumentTable, 5000

  clearDocumentTableInterval = (complete) ->
    if complete == true
      clearInterval setDocumentTableInterval

  refreshDocumentTable = ->
    $('#documents_table').bootstrapTable('refresh', {silent: "true"})
    complete = true
    $('span').each ->
      if $(this).hasClass('processing')
        complete = false
    clearDocumentTableInterval(complete)

  $(document).on 'click', '.edit-document', ->
    document_id = $(this).data('document_id')
    $.ajax
      type: 'GET'
      url: "/documents/#{document_id}/edit.js"

  $(document).on 'click', 'a.remove-document', ->
    document_id = $(this).data('document_id')
    del = confirm "Are you sure you want to delete this document?"
    if del
      if $(this).parent().siblings("td.viewed_at").text() == ""
        add_to_report_notification_count($(this).data('documentable_type'), -1)
      $.ajax
        type: 'DELETE'
        url: "/documents/#{document_id}.js"

  $(document).on 'change', "#organization_select", ->
    org_ids = $(this).val()
    if org_ids != null
      $.ajax
        type: 'GET'
        url: "reports/update_protocols_dropdown"
        data: { org_ids: org_ids }

  if $("body.documents-index").length > 0
    $(document).on 'click', 'a.attached_file', ->
      update_view_on_download_new_report $(this), 'table.documents', 'Identity'

(exports ? this).update_view_on_download_new_report = (element, table_to_update, documentable_type) ->
  row_index = element.parents().eq(1).attr("data-index")

  date_downloaded_element = element.parent().siblings("td.viewed_at")

  if date_downloaded_element.text().length == 0
    add_to_report_notification_count(documentable_type, -1)
    
    utcdate = moment().format(I18n["documents"]["date_time_formatter_js"])

    $(table_to_update).bootstrapTable 'updateCell', 
      index: row_index
      field: 'read_state'
      value: utcdate

(exports ? this).refreshDocumentsTables = ->
  $('#documents_table').bootstrapTable('refresh', {silent: "true"})
  $('#reports_table').bootstrapTable('refresh', {silent: "true"})
  