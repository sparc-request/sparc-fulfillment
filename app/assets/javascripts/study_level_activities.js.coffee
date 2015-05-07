$ ->

  # Line Item Bindings

  $(document).on 'click', ".otf_service_new", ->
    protocol_id = $('#protocol_id').val()
    data = protocol_id: protocol_id
    $.ajax
      type: 'GET'
      url: "/line_items/new"
      data: data

  $(document).on 'change', '.components > .selectpicker', ->
    line_item_id = $(this).parents('.row.line_item').data('id')
    data = components: $(this).val()
    $.ajax
      type: 'PATCH'
      url: "/line_items/#{line_item_id}/update_components"
      data: data

  $(document).on 'click', '.otf_notes', ->
    line_item_id = $(this).parents('.row.line_item').data('id')
    type = 'LineItem'
    data  = note:
              notable_id: line_item_id,
              notable_type: type
    $.ajax
      type: 'GET'
      url: '/notes.js'
      data: data

  $(document).on 'click', 'button.note.line_item.new',  ->
    id = $(this).data('notable-id')
    type = 'LineItem'
    data  = note:
              notable_id: id,
              notable_type: type
    $.ajax
      type: 'GET'
      url: '/notes/new.js'
      data: data

  $(document).on 'click', '.otf_documents', ->
    line_item_id = $(this).parents('.row.line_item').data('id')
    alert 'view line_item documents modal here'

  $(document).on 'click', '.otf_edit', ->
    line_item_id = $(this).parents('.row.line_item').data('id')
    $.ajax
      type: 'GET'
      url: "/line_items/#{line_item_id}/edit"

  # Fulfillment Bindings

  $(document).on 'click', '.otf_fulfillment_new', ->
    line_item_id = $(this).parents('.fulfillments').data('id')
    data = line_item_id: line_item_id
    $.ajax
      type: 'GET'
      url: "/fulfillments/new"
      data: data

  $(document).on 'click', '.fulfillment_notes', ->
    fulfillment_id = $(this).parents('.row.fulfillment').data('id')
    type = 'Fulfillment'
    data  = note:
              notable_id: fulfillment_id,
              notable_type: type
    $.ajax
      type: 'GET'
      url: '/notes.js'
      data: data

  $(document).on 'click', 'button.note.fulfillment_note.new',  ->
    id = $(this).data('notable-id')
    type = 'Fulfillment'
    data  = note:
              notable_id: id,
              notable_type: type
    $.ajax
      type: 'GET'
      url: '/notes/new.js'
      data: data

  $(document).on 'click', '.fulfillment_documents', ->
    fulfillment_id = $(this).parents('.row.fulfillment').data('id')
    alert 'view fulfillment documents modal here'

  $(document).on 'click', '.otf_fulfillment_edit', ->
    fulfillment_id = $(this).parents('.row.fulfillment').data('id')
    $.ajax
      type: 'GET'
      url: "/fulfillments/#{fulfillment_id}/edit"

  # Accordion Display Binding

  $(document).on 'click', '.otf_fulfillments', ->
    id = $(this).parents('.row.line_item').data('id')
    table = $("#fulfillments_list_#{id}")
    span = $(this).children('.glyphicon')
    if table.hasClass('slide-active')
      table.removeClass('slide-active')
      table.addClass('slide-inactive')
      span.removeClass("glyphicon-chevron-down")
      span.addClass("glyphicon-chevron-right")
      table.slideToggle()
    else
      activeSlide = $('.slide-active')
      if activeSlide.length != 0
        activeSpan = $(".glyphicon-chevron-down")
        activeSlide.removeClass('slide-active')
        activeSlide.addClass('slide-inactive')
        activeSpan.removeClass("glyphicon-chevron-down")
        activeSpan.addClass("glyphicon-chevron-right")
        activeSlide.slideToggle()
      table.removeClass('slide-inactive')
      table.addClass('slide-active')
      span.removeClass("glyphicon-chevron-right")
      span.addClass("glyphicon-chevron-down")
      table.slideToggle()

