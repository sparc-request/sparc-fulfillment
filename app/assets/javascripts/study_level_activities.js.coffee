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
    data = components: $(this).val(), line_item_id: line_item_id
    $.ajax
      type: 'PUT'
      url: "/components/update"
      data: data

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

  $(document).on 'click', '.otf_fulfillment_edit', ->
    fulfillment_id = $(this).parents('.row.fulfillment').data('id')
    $.ajax
      type: 'GET'
      url: "/fulfillments/#{fulfillment_id}/edit"

  $(document).on 'click', '.otf_delete', ->
    line_item_id = $(this).parents(".row.line_item").data('id')
    del = confirm "Are you sure you want to delete the selected Study Level Activity from this protocol"
    if del
      $.ajax
        type: "DELETE"
        url: "/line_items/#{line_item_id}"
  # Accordion Display Binding

  $(document).on 'click', '.otf_fulfillments', ->
    id = $(this).parents('.row.line_item').data('id')
    table = $("#fulfillments_list_#{id}")
    span = $(this).children('.glyphicon')
    if table.hasClass('slide-active')
      update_tooltip($(this), "View Fulfillments")
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

      update_tooltip($(this), "Hide Fulfillments")
      table.removeClass('slide-inactive')
      table.addClass('slide-active')
      span.removeClass("glyphicon-chevron-right")
      span.addClass("glyphicon-chevron-down")
      table.slideToggle()

