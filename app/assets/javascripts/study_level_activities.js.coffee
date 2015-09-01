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
    line_item_id = $(this).parents("table").bootstrapTable("getData")[row_index].id
    data = components: $(this).val(), line_item_id: line_item_id
    $.ajax
      type: 'PUT'
      url: "/components/update"
      data: data

  $(document).on 'click', '.otf_edit', ->
    row_index   = $(this).parents("tr").data("index")
    line_item_id = $(this).parents("table").bootstrapTable("getData")[row_index].id
    $.ajax
      type: 'GET'
      url: "/line_items/#{line_item_id}/edit"

  $(document).on 'click', '.otf_delete', ->
    row_index   = $(this).parents("tr").data("index")
    line_item_id = $(this).parents("table").bootstrapTable("getData")[row_index].id
    del = confirm "Are you sure you want to delete the selected Study Level Activity from this protocol"
    if del
      $.ajax
        type: "DELETE"
        url: "/line_items/#{line_item_id}"

  $('table.study_level_activities').on 'click', 'td:not(td.components):not(td.options)', ->
    row_index   = $(this).parents("tr").data("index")
    line_item_id = $(this).parents("table").bootstrapTable("getData")[row_index].id
    if $('#fulfillments_table_area').hasClass('slide_active') # if fulfillment table shown
      $('#fulfillments_table_area').removeClass('slide_active') # remove active class
      $("tr").removeClass("bs-highlighted") # remove highlighting from clicked row
      if $("#fulfillments_table_area").attr('data-line_item_id') == "#{line_item_id}" # fulfillments for clicked line item already displayed
        $('#fulfillments_table_area').slideUp() # hide fulfillments
      else # a new line item has been clicked
        $(this).parents("tr").addClass("bs-highlighted") # highlight clicked row
        $('#fulfillments_table_area').slideUp('normal', 'swing', -> # on hide completion, call for new fulfillments
          $.ajax
            type: 'GET'
            url: "/fulfillments"
            data: "line_item_id" : line_item_id
        )
    else # not already displayed
      $(this).parents("tr").addClass("bs-highlighted") # highlight clicked row
      $.ajax # call for new fulfillments
        type: 'GET'
        url: "/fulfillments"
        data: "line_item_id" : line_item_id

  # Fulfillment Bindings

  $(document).on 'click', '.otf_fulfillment_new', ->
    line_item_id = $(this).data('line-item-id')
    data = line_item_id: line_item_id
    $.ajax
      type: 'GET'
      url: "/fulfillments/new"
      data: data

  $(document).on 'click', '.otf_fulfillment_edit', ->
    row_index   = $(this).parents("tr").data("index")
    fulfillment_id = $(this).parents("table").bootstrapTable("getData")[row_index].id
    $.ajax
      type: 'GET'
      url: "/fulfillments/#{fulfillment_id}/edit"
