$("#fulfillments_row").attr('data-line_item_id', "<%= @line_item.id %>")
$("#fulfillments_row").html("<%= escape_javascript(render(:partial =>'study_level_activities/fulfillment_buttons', locals: {line_item: @line_item})) %>");
$("#fulfillments_row").prev("tr").first().find(".otf_fulfillments > .glyphicon").removeClass("glyphicon-refresh").addClass("glyphicon-chevron-down").parents("button").attr('data-original-title', 'Hide Fulfillment Buttons')
$("#modal_area").html("<%= escape_javascript(render(:partial =>'study_level_activities/fulfillments_table', locals: {line_item: @line_item, header_text: 'Fulfillments List'})) %>");
$("#modal_place").modal 'show'
$("#fulfillments-table").bootstrapTable()
