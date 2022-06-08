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

  $(document).on 'post-body.bs.table ajax:complete', (e) ->
    initializeSelectpickers()
    initializeDateTimePickers()
    initializeTooltips()
    initializePopovers()
    initializeToggles()
    initializeTables()
    setRequiredFields()

  $(document).on 'refresh.bs.table', ->
    $('.popover').popover('hide')

  #Login Form JS
  $(document).on 'click', '#outsideUserLogin', ->
    $('form#new_identity').removeClass('d-none')

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
    editable_object = $(this)
    if ($anchor = editable_object.find('a')).length
      # Anchor has an href to perform a request
      if !$anchor.hasClass('disabled') && $anchor.attr('href') != 'javascript:void(0)'
        editable_object.addClass('disabled')
        $anchor.addClass('disabled')
        # If the requst should be remote, send an AJAX request
        if $anchor.data('remote')
          $anchor.prop('disabled', true)
          $.ajax
            method:   $anchor.data('method') || 'GET'
            dataType: 'script'
            url:      $anchor.attr('href')
            success: ->
              editable_object.removeClass('disabled')
              $anchor.removeClass('disabled')
              $anchor.prop('disabled', false)
        # Else change the page location
        else
          window.location.href = $anchor.attr('href')
      # Anchor has a toggle instead of an href
      else if toggle = $anchor.data('toggle')
        $("[data-toggle=#{toggle}").not($anchor)[toggle]('hide')
        $anchor[toggle]('toggle')




  stickybits('.position-sticky, .sticky-top')


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
      if !$('span.notification-badge.reports-tab-badge small').length
        $('<span class="badge badge-pill badge-c badge-danger notification-badge reports-tab-badge"><small>0</small></span>').appendTo($('#reportsTabLink span.position-relative'))
      notification_text = $('span.notification-badge.reports-tab-badge small')
      notification_bubble = $('span.notification-badge.reports-tab-badge')
    when 'Identity'
      if !$('.identity_report_notifications').length
        $('<span class="badge badge-pill badge-c badge-danger notification-badge identity_report_notifications">0</span>').appendTo($('#navbarLinks .documents_nav'))
      notification_bubble = $('span.notification-badge.identity_report_notifications')
      notification_text = notification_bubble

  new_notification_count = (parseInt(notification_text.text()) + amount)
  notification_text.text(new_notification_count)

  if new_notification_count <= 0
    notification_bubble.remove()
