$("#fulfillments_table_area").attr('data-line_item_id', "<%= @line_item.id %>")
$("#fulfillments_table_area").html("<%= escape_javascript(render(:partial =>'study_level_activities/fulfillments_table', locals: {line_item: @line_item})) %>");
$("#fulfillments-table").bootstrapTable()
$(".selectpicker").selectpicker()
$('#fulfillments_table_area').slideDown()
$('#fulfillments_table_area').addClass('slide_active')