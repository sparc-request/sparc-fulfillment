# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  change_page = (obj) ->
    data =
      'arm_id': obj.data('arm_id'),
      'page'  : obj.attr('page')
    $.ajax
      type: 'GET'
      url:  '/service_calendar/change_page'
      data: data

  $('.glyphicon-arrow-right').on 'click', ->
    change_page $(this)

  $('.glyphicon-arrow-left').on 'click', ->
    change_page $(this)

  $('.visit').on 'change', ->
    data =
      'visit_id': $(this).val()
      'checked':  $(this).prop('checked')
    $.ajax
      type: 'PUT'
      url:  '/service_calendar/check_visit'
      data: data

  $('.visit_name').on 'change', ->
    visit_group_id = $(this).data('visit_group_id')
    name = $(this).val()
    data =
      'visit_group_id': visit_group_id
      'name':           name
    $.ajax
      type: 'PUT'
      url:  '/service_calendar/change_visit_name'
      data: data
      success: ->
        # Need to find out if this is actually necessary
        # or if we can use faye
        $(".visit_dropdown option[value=#{visit_group_id}]").text(name)

  $('.check_row').on 'click', ->
    check = $(this).attr('check')
    data =
      'line_item_id': $(this).data('line_item_id'),
      'check':        check
    $.ajax
      type: 'PUT'
      url:  '/service_calendar/check_row'
      data: data
      success: =>
        # Check off visits
        # Update text fields
        if check == 'true'
          $(this).removeClass('glyphicon-ok').addClass('glyphicon-remove')
          $(this).attr('check', 'false')
        else
          $(this).removeClass('glyphicon-remove').addClass('glyphicon-ok')
          $(this).attr('check', 'true')
