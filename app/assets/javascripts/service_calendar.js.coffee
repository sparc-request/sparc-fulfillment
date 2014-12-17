# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  change_page = (obj) ->
    data =
        'arm_id': obj.data('arm_id'),
        'page'  : obj.attr('page')
    console.log data
    $.ajax
      type: 'GET'
      url:  '/service_calendar/change_page'
      data: data

  $('.glyphicon-arrow-right').on 'click', ->
    change_page $(this)

  $('.glyphicon-arrow-left').on 'click', ->
    change_page $(this)