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
  $(document).on 'click', '.report-button:not(.disabled):not(.dropdown-toggle)', ->
    generateReport($(this))

generateReport = ($element) ->
  $element.addClass('disabled')
  $.ajax
    method: 'POST'
    dataType: 'json'
    url: $element.data('url')
    success: (data) ->
      documentId = data.document.id
      setReportLoading($element)
      reportInterval = setInterval((->
        getDocumentState($element, documentId, reportInterval)
        ), 1500)
    error: (data) ->
      $element.removeClass('disabled')

getDocumentState = ($element, documentId, interval) ->
  $.ajax
    method: 'GET'
    dataType: 'json'
    url: "/documents/#{documentId}.json"
    success: (data) ->
      switch data.document.state
        when 'Completed'
          clearInterval(interval)
          $element.removeClass('disabled')
          add_to_report_notification_count(data.document.documentable_type, 1)
          setReportFinished($element)
          $dropdown = addReportDropdown($element, documentId)

          $dropdown.find('.download-report').one 'click', ->
            update_view_on_download_new_report $("a.attached_file[data-id=#{documentId}]") ,'table.protocol_reports', 'Protocol'

          $dropdown.find('.regenerate-report').one 'click', ->
            $button = $dropdown.find('.report-button').clone()
            $dropdown.replaceWith($button)
            generateReport($button)
        when 'Error'
          $element.removeClass('disabled')
          setReportError($element)

setReportLoading = ($element) ->
  $element.
    addClass('btn-secondary').
    removeClass('btn-success btn-warning').
    find('i').
      addClass('fa-sync rotate').
      removeClass('fa-file-alt fa-file-download fa-exclamation-circle')

setReportFinished = ($element) ->
  $element.
    addClass('btn-success').
    removeClass('btn-secondary btn-warning').
    find('i').
      addClass('fa-file-download').
      removeClass('fa-sync rotate')

setReportError = ($element) ->
  $element.
    addClass('btn-warning').
    removeClass('btn-secondary btn-success').
    find('i').
      addClass('fa-exclamation-circle').
      removeClass('fa-file-alt fa-sync rotate')

addReportDropdown = ($element, documentId) ->
  $button       = $element.clone()
  $dropdown     = $("<div class='dropdown'></div>")
  $dropdownMenu = $("
    <ul class='dropdown-menu dropdown-menu-right'>
      <a class='dropdown-item download-report' href='/documents/#{documentId}' target='_blank'><i class='fas fa-download mr-2'></i>#{I18n.t('reports.download')}</a>
      <a class='dropdown-item regenerate-report' href='javascript:void(0)'><i class='fas fa-sync mr-2'></i>#{I18n.t('reports.regenerate')}</a>
    </ul>
  ")
  $button.addClass('dropdown-toggle').attr('data-toggle', 'dropdown')
  $dropdown.append($button)
  $dropdown.append($dropdownMenu)
  $element.replaceWith($dropdown)
  return $dropdown
