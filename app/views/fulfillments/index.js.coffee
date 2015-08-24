$("#modal_area").html("<%= escape_javascript(render(:partial =>'study_level_activities/fulfillments_table', locals: {line_item: @line_item})) %>");
$("#fulfillments-table").bootstrapTable()
$("#modal_place").modal 'show'
$(".selectpicker").selectpicker()
