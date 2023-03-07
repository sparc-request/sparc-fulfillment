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

  $(document).on 'load-success.bs.table', 'table.core', ->
    $('.group-of-one').closest('tr.groupBy').remove()
    $('#appointmentContainer').removeClass('d-none')

  $(document).on 'click', 'tr.groupBy', ->
    $(this).find('.group-icon').toggleClass('fa-chevron-right fa-chevron-down')

  $(document).on 'hide.datetimepicker', '.procedure-completed-datepicker', ->
    Rails.fire($(this).parents('form')[0], 'submit')

  $(document).on 'hide.datetimepicker', '.procedure-invoiced-date-datepicker', ->
    Rails.fire($(this).parents('form')[0], 'submit')

  $(document).on('mouseenter', '.appointment-status-buttons button:not(.disabled)', ->
    $(this).siblings('.active').removeClass('active')
    $(this).addClass('active')
  ).on('mouseleave', '.appointment-status-buttons', ->
    selected = $(this).data('selected')
    $(this).find('.active').removeClass('active')
    $(this).find("button[data-status=#{selected}]").addClass('active')
  )

  $(document).on 'click', '.appointment-status-buttons button:not(.disabled)', ->
    $btn        = $(this)
    status      = $btn.data('status')
    url         = $btn.data('url')
    old_status  = $btn.parents('.appointment-status-buttons').data('selected')

    if status != old_status
      $btn.parents('.appointment-status-buttons').data('selected', status)

      if status == 'complete' || status == 'unstarted'
        $.ajax
          method: 'PUT'
          dataType: 'script'
          url: url
      else
        $.ajax
          method: 'GET'
          dataType: 'script'
          url: url
          data:
            partial: 'incomplete'
          success: ->
            $('#modalContainer').one 'hide.bs.modal', ->
              $btn.parents('.appointment-status-buttons').data('selected', old_status)
              $btn.removeClass('active')
              $btn.siblings("button[data-status=#{old_status}]").addClass('active')

  $(document).on 'click', '.procedure_move_button',  ->
    id = $(this).data('procedure-id')
    movement_type = $(this).data('movement-type')
    table = $(this).parents('table.core')
    $.ajax
      type: 'PUT'
      data:
        movement_type: movement_type
      url: "/procedures/change_procedure_position/#{id}.js"

  # $(document).on 'click', '.procedure-invoiced-date-edit', ->
  #   id = $(this).data('procedure_id')
  #   #procedure_id = $(this).data('procedure_id')
  #   appointment_id = $(this).data('appointment_id')
  #   $.ajax
  #     type: 'GET'
  #     url: "/appointments/#{appointment_id}/procedures/#{id}/invoiced_date_edit"

(exports ? this).proceduresGroupFormatter = (value, idx, data) ->
  single_procedure = if data.length == 1 then 'group-of-one' else ''
  badge = '<strong class="badge badge-primary px-2 my-1 mr-2">' + data.length + '</strong>'
  icon = '<i class="fas fa-chevron-right group-icon ml-2"></i>'
  formatted_value = '<p class="lead mb-0 w-75 ' + single_procedure + '">' + badge + value + icon + '</p>'

(exports ? this).proceduresCollapsedGroups = (groupKey, items) ->
  if items.length > 1
    [groupKey]
  else
    []
