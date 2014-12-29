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

  $(document).on 'click', '.glyphicon-arrow-right', ->
    change_page $(this)

  $(document).on 'click', '.glyphicon-arrow-left', ->
    change_page $(this)

  $(document).on 'change', '.visit_dropdown', ->
    page = $(this).find('option:selected').attr('parent_page')
    cur_page = $(this).attr('page')

    if page == undefined || page == false
      page = $(this).val()

    # Early out when selecting a visit that is already shown
    if page == cur_page
      $(this).val(page)
      return

    data =
      'arm_id': $(this).data('arm_id')
      'page'  : page
    $.ajax
      type: 'GET'
      url:  '/service_calendar/change_page'
      data: data

  $(document).on 'change', '.visit', ->
    data =
      'visit_id': $(this).val()
      'checked':  $(this).prop('checked')
    $.ajax
      type: 'PUT'
      url:  '/service_calendar/check_visit'
      data: data

  $(document).on 'change', '.visit_name', ->
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

  $(document).on 'click', '.check_row', ->
    check = $(this).attr('check')
    line_item_id = $(this).data('line_item_id')
    data =
      'line_item_id': line_item_id,
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
          $(".visits_for_#{line_item_id} input[type=checkbox]").prop('checked', true)
        else
          $(this).removeClass('glyphicon-remove').addClass('glyphicon-ok')
          $(this).attr('check', 'true')
          $(".visits_for_#{line_item_id} input[type=checkbox]").prop('checked', false)