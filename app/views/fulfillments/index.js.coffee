$("#fulfillments_row").attr('data-line_item_id', "<%= @line_item.id %>")
$("#modal_area").html("<%= escape_javascript(render(:partial =>'study_level_activities/fulfillments_table', locals: {line_item: @line_item, header_text: 'Fulfillments List'})) %>");
$("#modal_place").modal 'show'
$("#fulfillments-table").bootstrapTable()
