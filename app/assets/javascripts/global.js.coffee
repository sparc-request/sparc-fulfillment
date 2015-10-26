$ ->
  $('[data-toggle="tooltip"]').tooltip()
  $("input[placeholder='Search']").wrap("<div class='input-group search-bar'/>")
  $("<span class='input-group-addon clear_search glyphicon glyphicon-remove' data-toggle='true' style='display:none;'></span>").insertAfter($("input[placeholder='Search']"))
  $(".selectpicker").selectpicker()

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

  $(document).on 'click', 'button.notes.list',  ->
    id = $(this).data('notable-id')
    type = $(this).data('notable-type')
    data          = note:
                      notable_id: id,
                      notable_type: type
    $.ajax
      type: 'GET'
      url: '/notes.js'
      data: data

  $(document).on 'click', 'button.note.new',  ->
    id = $(this).data('notable-id')
    type = $(this).data('notable-type')
    data          = note:
                      notable_id: id,
                      notable_type: type
    $.ajax
      type: 'GET'
      url: '/notes/new.js'
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

# Add a tooltip to elt (e.g., "#visits_219_insurance_billing_qty")
# containing content, which disappears after about 3 seconds.
(exports ? this).error_tooltip_on = (elt, content) ->
  $elt = $(elt)
  $elt.attr('data-toggle', 'tooltip').attr('title', content)
  $elt.tooltip({container: 'body'})
  $elt.tooltip('show')
  delay = (ms, func) -> setTimeout func, ms
  delay 3000, -> $elt.tooltip('destroy')

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

(exports ? this).update_tooltip = (object, string) ->
  $(object).tooltip('hide')
  $(object).attr('data-original-title', string)
  $(object).tooltip('fixTitle')
