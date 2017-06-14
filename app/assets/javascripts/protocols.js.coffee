# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

  if $("body.protocols-index").length > 0

    # Delete Protocol tab-remembering cookie
    $.removeCookie("active-protocol-tab")
    # Delete Study Schedule tab-remembering cookie
    $.removeCookie("active-schedule-tab")

    $(".bootstrap-table .fixed-table-toolbar").
      prepend('<div class="columns btn-group pull-right financial--view" data-toggle="buttons"><label class="btn btn-default financial" title="Financial View"><input type="radio" autocomplete="off" value="financial"><i class="glyphicon glyphicon-usd"></i></label><label class="btn btn-default management" title="Management View"><input type="radio" autocomplete="off" value="management"><i class="glyphicon glyphicon-book"></i></label></div>')

    $('table.protocols').on 'click', 'td:not(td.coordinators)', ->
      if $(this).find("div.card-view").length == 0
        row_index   = $(this).parents("tr").data("index")
        protocol_id = $(this).parents("table").bootstrapTable("getData")[row_index].id

        window.location = "/protocols/#{protocol_id}"

    #Index table events
    $(document).on 'change', '#index_selectpicker', ->
      status = $(this).val()
      $('#protocol-list').bootstrapTable('refresh', {url: "/protocols.json?status=" + status, silent: "true"})

    $(document).on 'click', '.financial', ->
      $('#protocol-list').removeClass('custom_striped')
      $('#protocol-list').addClass('custom_striped_financial')
      $('#protocol-list').bootstrapTable('hideColumn', 'updates')
      $('#protocol-list').bootstrapTable('hideColumn', 'status')
      $('#protocol-list').bootstrapTable('hideColumn', 'short_title')
      $('#protocol-list').bootstrapTable('hideColumn', 'coordinators')
      $('#protocol-list').bootstrapTable('hideColumn', 'irb_approval_date')
      $('#protocol-list').bootstrapTable('showColumn', 'start_date')
      $('#protocol-list').bootstrapTable('showColumn', 'end_date')
      $('#protocol-list').bootstrapTable('showColumn', 'total_at_approval')
      $('#protocol-list').bootstrapTable('showColumn', 'percent_subsidy')
      $('#protocol-list').bootstrapTable('showColumn', 'subsidy_committed')
      $('#protocol-list').bootstrapTable('showColumn', 'subsidy_expended')

    $(document).on 'click', '.management', ->
      $('#protocol-list').addClass('custom_striped')
      $('#protocol-list').removeClass('custom_striped_financial')
      $('#protocol-list').bootstrapTable('showColumn', 'updates')
      $('#protocol-list').bootstrapTable('showColumn', 'status')
      $('#protocol-list').bootstrapTable('showColumn', 'short_title')
      $('#protocol-list').bootstrapTable('showColumn', 'coordinators')
      $('#protocol-list').bootstrapTable('showColumn', 'irb_approval_date')
      $('#protocol-list').bootstrapTable('hideColumn', 'start_date')
      $('#protocol-list').bootstrapTable('hideColumn', 'end_date')
      $('#protocol-list').bootstrapTable('hideColumn', 'total_at_approval')
      $('#protocol-list').bootstrapTable('hideColumn', 'percent_subsidy')
      $('#protocol-list').bootstrapTable('hideColumn', 'subsidy_committed')
      $('#protocol-list').bootstrapTable('hideColumn', 'subsidy_expended')

    $(window).scroll ->
      if $(this).scrollTop() > 50
        $('.back-to-top').removeClass('hidden')
      else
        $('.back-to-top').addClass('hidden')

(exports ? this).number_to_percent = (value) ->
  value + '%'
