$ ->

  $('.date_started_field').datetimepicker(format: 'MM-DD-YYYY', useCurrent: false)
  $('.fulfillment_date_field').datetimepicker(format: 'MM-DD-YYYY', useCurrent: false)

  $(document).on 'click', '.otf_notes_new', ->
    line_item_id = $(this).parents('.row.line_item').data('id')
    alert 'add note here'

  $(document).on 'click', '.otf_notes', ->
    line_item_id = $(this).parents('.row.line_item').data('id')
    alert 'view notes here'

  $(document).on 'click', '.otf_documents_new', ->
    line_item_id = $(this).parents('.row.line_item').data('id')
    alert 'add document here'

  $(document).on 'click', '.otf_documents', ->
    line_item_id = $(this).parents('.row.line_item').data('id')
    alert 'view documents here'

  $(document).on 'click', '.otf_fulfillments_new', ->
    line_item_id = $(this).parents('.row.line_item').data('id')
    alert 'add fulfillment here'

  $(document).on 'click', '.otf_fulfillments', ->
    table = $(this).parents('.fulfillments').next()
    if table.hasClass('slide-active')
      table.removeClass('slide-active')
      table.addClass('slide-inactive')
      table.slideToggle()
    else
      activeSlide = $('.slide-active')
      if activeSlide.length != 0
        activeSlide.removeClass('slide-active')
        activeSlide.addClass('slide-inactive')
        activeSlide.slideToggle()
      table.removeClass('slide-inactive')
      table.addClass('slide-active')
      table.slideToggle()

  $(document).on 'change', '.quantity_requested_field', ->
    line_item_id = $(this).parents('.row.line_item').data('id')
    new_qty = $(this).val()
    alert "change qty requested to: #{new_qty}"

  $('.date_started_field').on 'dp.change', (e) ->
    line_item_id = $(this).parents('.row.line_item').data('id')
    new_date = e.date
    alert "change start date now to: #{new_date}"