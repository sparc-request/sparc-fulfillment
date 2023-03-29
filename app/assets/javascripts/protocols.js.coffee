# Copyright © 2011-2023 MUSC Foundation for Research Development~
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

  if $("#protocols").length
    # Delete Protocol tab-remembering cookie
    Cookies.remove("active-protocol-tab")
    # Delete Study Schedule tab-remembering cookie
    Cookies.remove("active-schedule-tab")

    $(".fixed-table-toolbar").prepend('
      <div class="btn-group float-left financial--view mr-1" data-toggle="buttons">
        <button class="btn btn-light mb-0 active management" title="Requests View" data-toggle="tooltip">
          <input type="radio" autocomplete="off" class="d-none" value="management">
          <i class="fas fa-book"></i> Requests
        </button>
        <button class="btn btn-light mb-0 financial" title="Financial View" data-toggle="tooltip">
          <input type="radio" autocomplete="off" class="d-none" value="financial">
          <i class="fas fa-dollar-sign"></i> Financial
        </button>
      </div>
    ')

    #Index table events
    $(document).on 'change', '#protocol_status_filter', ->
      status = $(this).val()
      if status == "all"
        $('#protocols').bootstrapTable('refresh', {url: "/protocols.json", silent: "true"})
      else
        $('#protocols').bootstrapTable('refresh', {url: "/protocols.json?status=" + status, silent: "true"})

    $(document).on 'click', '.financial:not(.active)', ->
      $(this).addClass('active')
      $('.management').removeClass('active')
      $('#protocols').
        bootstrapTable('hideColumn', 'status').
        bootstrapTable('hideColumn', 'short_title').
        bootstrapTable('hideColumn', 'coordinators').
        bootstrapTable('hideColumn', 'irb_approval_date').
        bootstrapTable('showColumn', 'start_date').
        bootstrapTable('showColumn', 'end_date').
        bootstrapTable('showColumn', 'total_at_approval').
        bootstrapTable('showColumn', 'percent_subsidy').
        bootstrapTable('showColumn', 'subsidy_committed')

    $(document).on 'click', '.management:not(.active)', ->
      $(this).addClass('active')
      $('.financial').removeClass('active')
      $('#protocols').bootstrapTable('showColumn', 'status').
        bootstrapTable('showColumn', 'short_title').
        bootstrapTable('showColumn', 'coordinators').
        bootstrapTable('showColumn', 'irb_approval_date').
        bootstrapTable('hideColumn', 'start_date').
        bootstrapTable('hideColumn', 'end_date').
        bootstrapTable('hideColumn', 'total_at_approval').
        bootstrapTable('hideColumn', 'percent_subsidy').
        bootstrapTable('hideColumn', 'subsidy_committed')

    $(document).on 'click', '#coordinator-menu', (e) ->
      e.stopPropagation()

  # Load tab on page load
  if $('#protocolTabs').length
    $.ajax
      method: 'get'
      dataType: 'script'
      url: $('#protocolTabs .nav-tabs .nav-link.active').attr('href')
      success: ->
        $('#requestLoading').removeClass('show active')

(exports ? this).number_to_percent = (value) ->
  value + '%'
