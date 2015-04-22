$ ->

  $('.date_started_field').datetimepicker(format: 'MM-DD-YYYY', useCurrent: false)

  $(document).on 'click', '.otf_notes_new', ->
    line_item_id = $(this).parents('.row.one_time_fee').data('id')
    alert 'add note here'

  $(document).on 'click', '.otf_notes', ->
    line_item_id = $(this).parents('.row.one_time_fee').data('id')
    alert 'view notes here'

  $(document).on 'click', '.otf_documents_new', ->
    line_item_id = $(this).parents('.row.one_time_fee').data('id')
    alert 'add document here'

  $(document).on 'click', '.otf_documents', ->
    line_item_id = $(this).parents('.row.one_time_fee').data('id')
    alert 'view documents here'

  $(document).on 'click', '.otf_fulfillments_new', ->
    line_item_id = $(this).parents('.row.one_time_fee').data('id')
    alert 'add fulfillment here'

  $(document).on 'click', '.otf_fulfillments', ->
    line_item_id = $(this).parents('.row.one_time_fee').data('id')
    $("#fulfillments_table_#{line_item_id}").slideToggle()

  $(document).on 'change', '.quantity_requested_field', ->
    line_item_id = $(this).parents('.row.one_time_fee').data('id')
    new_qty = $(this).val()
    alert "change qty requested to: #{new_qty}"

  $('.date_started_field').on 'dp.change', (e) ->
    line_item_id = $(this).parents('.row.one_time_fee').data('id')
    new_date = e.date
    alert "change start date now to: #{new_date}"