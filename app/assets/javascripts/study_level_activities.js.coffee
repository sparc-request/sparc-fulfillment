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
    row_index   = $(this).parents("tr").data("index")
    line_item_id = $(this).parents("table.study_level_activities").bootstrapTable("getData")[row_index].id
    data = components: $(this).val(), line_item_id: line_item_id
    $.ajax
      type: 'PUT'
      url: "/components/update"
      data: data

  $(document).on 'click', '.otf_edit', ->
    row_index   = $(this).parents("tr").data("index")
    line_item_id = $(this).parents("table.study_level_activities").bootstrapTable("getData")[row_index].id
    $.ajax
      type: 'GET'
      url: "/line_items/#{line_item_id}/edit"

  $(document).on 'click', '.otf_delete', ->
    row_index   = $(this).parents("tr").data("index")
    line_item_id = $(this).parents("table.study_level_activities").bootstrapTable("getData")[row_index].id
    del = confirm "Are you sure you want to delete the selected Study Level Activity from this protocol"
    if del
      $.ajax
        type: "DELETE"
        url: "/line_items/#{line_item_id}"

  # Fulfillment Bindings

  $(document).on 'click', '.otf_fulfillment_new', ->
    line_item_id = $(this).data('line-item-id')
    data = line_item_id: line_item_id
    $.ajax
      type: 'GET'
      url: "/fulfillments/new"
      data: data

  $(document).on 'click', '.otf-fulfillment-list', ->
    line_item_id = $(this).data('line-item-id')
    data = line_item_id: line_item_id
    $.ajax
      type: 'GET'
      url: "/fulfillments"
      data: "line_item_id" : line_item_id

  $(document).on 'click', '.otf_fulfillment_edit', ->
    row_index   = $(this).parents("tr").data("index")
    fulfillment_id = $(this).parents("#fulfillments-table").bootstrapTable("getData")[row_index].id
    $.ajax
      type: 'GET'
      url: "/fulfillments/#{fulfillment_id}/edit"
