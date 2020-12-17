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
  $('html').addClass('ready')
  initializeSelectpickers()
  initializeDateTimePickers()
  initializeTooltips()
  initializePopovers()
  initializeToggles()
  initializeTables()
  setRequiredFields()

  stickybits('.position-sticky, .sticky-top')

  $(document).on 'load-success.bs.table search.bs.table sort.bs.table column-switch.bs.table ajax:complete', (e) ->
    initializeSelectpickers()
    initializeDateTimePickers()
    initializeTooltips()
    initializePopovers()
    initializeToggles()
    initializeTables()
    setRequiredFields()

  # Back To Top button scroll
  $(window).scroll ->
    if $(this).scrollTop() > 50
      $('#backToTop').removeClass('hide')
    else
      $('#backToTop').addClass('hide')

  $(document).on 'click', '#backToTop', ->
    $('html, body').animate({ scrollTop: 0 }, 'slow')

  $(document).on('mouseenter', '.editable:not(.active)', ->
    # Apply hover styles for editable table cells
    $anchor = $(this).find('a')
    if !$anchor.hasClass('disabled')
      $(this).addClass('active')
      $anchor.addClass('active')
      # If the anchor has a toggle like tooltip on hover, show it
      if (toggle = $anchor.data('toggle')) && !($anchor.data('trigger') == 'manual' || $anchor.data('trigger') == 'click')
        $("[data-toggle=#{toggle}").not($anchor)[toggle]('hide')
        $anchor[toggle]('toggle')
  ).on('mouseleave', '.editable.active', ->
    # Remove hover styles for editable table cells
    $anchor = $(this).find('a')
    $(this).removeClass('active focus')
    $anchor.removeClass('active focus')
    # If the anchor has a toggle like tooltip on hover, hide it
    if (toggle = $anchor.data('toggle')) && !($anchor.data('trigger') == 'manual' || $anchor.data('trigger') == 'click')
      $anchor[toggle]('hide')
  ).on('mousedown focus', '.editable:not(.focus)', ->
    # Apply focus styles for editable table cells
    $anchor = $(this).find('a')
    if !$anchor.hasClass('disabled')
      $(this).addClass('focus')
      $anchor.addClass('focus')
  ).on('mouseup focusout', '.editable.focus', ->
    # Remove focus styles for editable table cells
    $anchor = $(this).find('a')
    $(this).removeClass('focus')
    $anchor.removeClass('focus')
  )

  $(document).on 'click', '.editable', (event) ->
    # Perform requests when clicking editable table cells with anchors
    if ($anchor = $(this).find('a')).length
      # Anchor has an href to perform a request
      if !$anchor.hasClass('disabled') && $anchor.attr('href') != 'javascript:void(0)'
        $(this).addClass('disabled')
        $anchor.addClass('disabled')
        # If the requst should be remote, send an AJAX request
        if $anchor.data('remote')
          $anchor.prop('disabled', true)
          $.ajax
            method:   $anchor.data('method') || 'GET'
            dataType: 'script'
            url:      $anchor.attr('href')
            success:  $anchor.prop('disabled', false)
        # Else change the page location
        else
          window.location.href = $anchor.attr('href')
      # Anchor has a toggle instead of an href
      else if toggle = $anchor.data('toggle')
        $("[data-toggle=#{toggle}").not($anchor)[toggle]('hide')
        $anchor[toggle]('toggle')




  $('[data-toggle="tooltip"]').tooltip()
  $("input[placeholder='Search']").wrap("<div class='input-group search-bar'/>")
  $("<span class='input-group-addon clear_search glyphicon glyphicon-remove' data-toggle='true' style='display:none;'></span>").insertAfter($("input[placeholder='Search']"))
  $(".selectpicker").selectpicker()

  stickybits('.position-sticky, .sticky-top')

  $('#history-back').contextmenu
    target: '#history-menu',
    onItem: (context, e) ->
      window.location.href = $(e.target).attr('href')

  $('#history-back').tooltip()

  $(document).on 'all.bs.table', 'table', ->
    $(".selectpicker").selectpicker()
    $('[data-toggle="tooltip"]').tooltip()

  $(document).on 'search.bs.table', "table", (event, input)->
    unless input == ''
      $(".clear_search").show()

  $(document).on 'click', '.clear_search', ->
    $(this).siblings("input").val("").trigger("keyup")
    $(this).hide()

  $(document).on 'dp.hide', '.datetimepicker', ->
    $(this).blur()

  $(document).on 'click', 'button.notes.list',  ->
    unless $(this).hasClass('disabled')
      id = $(this).data('notable-id')
      type = $(this).data('notable-type')
      data = note:
          notable_id: id,
          notable_type: type
      $.ajax
        type: 'GET'
        url: '/notes.js'
        data: data

  $(document).on 'click', 'button.note.new',  ->
    id = $(this).data('notable-id')
    type = $(this).data('notable-type')
    data = note:
        notable_id: id,
        notable_type: type
    $.ajax
      type: 'GET'
      url: '/notes/new.js'
      data: data

  $(document).on 'click', 'button.note.cancel',  ->
    id = $(this).data('notable-id')
    type = $(this).data('notable-type')
    data = note:
      notable_id: id
      notable_type: type
    $.ajax
      type: 'GET'
      url: '/notes.js'
      data: data

  $(document).on 'click', 'button.documents.list', ->
    id = $(this).data('documentable-id')
    type = $(this).data('documentable-type')
    data  = document:
              documentable_id: id,
              documentable_type: type
    $.ajax
      type: 'GET'
      url: '/documents.js'
      data: data

  $(document).on 'click', 'button.document.new',  ->
    id = $(this).data('documentable-id')
    type = $(this).data('documentable-type')
    data  = document:
              documentable_id: id,
              documentable_type: type
    $.ajax
      type: 'GET'
      url: '/documents/new.js'
      data: data

(exports ? this).initializeSelectpickers = () ->
  $('.selectpicker').each ->
    $(this).selectpicker() if $(this).siblings('.dropdown-toggle').length == 0

(exports ? this).initializeDateTimePickers = () ->
  $('.datetimepicker.date:not(.time)').datetimepicker({ format: 'L' })
  $('.datetimepicker.time:not(.date)').datetimepicker({ format: 'LT' })
  $('.datetimepicker.date.time').datetimepicker()

(exports ? this).initializeTooltips = () ->
  $('.tooltip').tooltip('hide')
  $('[data-toggle=tooltip]').tooltip({ delay: { show: 250 }, animation: false })

(exports ? this).initializePopovers = () ->
  $('[data-toggle=popover]').popover()

(exports ? this).initializeToggles = () ->
  $('input[data-toggle=toggle]').bootstrapToggle()

(exports ? this).initializeTables = () ->
  $('[data-toggle=table]').bootstrapTable()

(exports ? this).setRequiredFields = () ->
  $('.required:not(.has-indicator)').addClass('has-indicator').append("<span class='required-indicator text-danger ml-1'>#{I18n.t('constants.required_fields.indicator')}</span>")
  $('.has-indicator:not(.required)').removeClass('has-indicator').children('.required-indicator').remove()
  
# Add a tooltip to elt (e.g., "#visits_219_insurance_billing_qty")
# containing content, which disappears after about 3 seconds.
(exports ? this).error_tooltip_on = (elt, content) ->
  $elt = $(elt)
  $elt.attr('data-toggle', 'tooltip').attr('title', content)
  $elt.tooltip({container: 'body'})
  $elt.tooltip('show')
  delay = (ms, func) -> setTimeout func, ms
  delay 3000, -> $elt.tooltip('destroy')

(exports ? this).update_tooltip = (object, string) ->
  $(object).tooltip('hide')
  $(object).attr('data-original-title', string)
  $(object).tooltip('fixTitle')

(exports ? this).add_to_report_notification_count = (documentable_type, amount) ->
  switch documentable_type
    when 'Protocol'
      if !$('.notification.protocol_report_notifications').length
        $('<span class="notification protocol_report_notifications">0</span>').appendTo($('#protocol-reports-tab'))
      notification_bubble = $('.notification.protocol_report_notifications')
    when 'Identity'
      if !$('.notification.identity_report_notifications').length
        $('<span class="notification identity_report_notifications">0</span>').appendTo($('a.documents'))
      notification_bubble = $('.notification.identity_report_notifications')
  notification_count = parseInt(notification_bubble.text())
  notification_bubble.text(notification_count + amount) if (notification_count + amount) >= 0
  notification_count = parseInt(notification_bubble.text())
  if notification_count == 0
    notification_bubble.remove();

### Add "exclude_in_export" class to columns you want excluded from export and then pass in table ID ###
window.exclude_from_export = (table_id) ->
  excluded_cols = []
  $('#'+table_id + ' .exclude_in_export').each ->
    excluded_cols.push $(this).closest('th').index()
  if excluded_cols.length
    $('#'+table_id).data('export-options').ignoreColumn = excluded_cols
