$ ->
  $('[data-toggle="tooltip"]').tooltip()

  window.update_tooltip = (object, string) ->
    $(object).tooltip('hide')
    $(object).attr('data-original-title', string)
    $(object).tooltip('fixTitle')

  $(document).on 'search.bs.table', "table", ->
    if not $(".clear_search").length
      $("input[placeholder='Search']").wrap("<div class='input-group'/>")
      $("<span class='input-group-addon clear_search glyphicon glyphicon-remove'></span>").insertAfter($("input[placeholder='Search']"))

  $(document).on 'click', '.clear_search', ->
    $(this).siblings("input").val("").trigger("keyup")
    $("table").bootstrapTable('refresh', {query: {MRN: "1955997"}})
    $('.input-group').children(".clear_search").remove()


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
