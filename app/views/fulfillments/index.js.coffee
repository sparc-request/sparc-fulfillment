$("#fulfillments_row").attr('data-line_item_id', "<%= @line_item.id %>")
$("#fulfillments_row").html("<%= escape_javascript(render(:partial =>'study_level_activities/fulfillments_table', locals: {line_item: @line_item})) %>");
$("#fulfillments-table").bootstrapTable()
