$("#modal_errors").html("<%= escape_javascript(render(:partial =>'shared/modal_errors', locals: {errors: @errors})) %>")
if $("#modal_errors > .alert.alert-danger > p").length == 0
  $(".line_item[data-id=<%= @line_item.id %>] > .qty_rem").html("<%= @line_item.quantity_remaining %>")
  $(".line_item[data-id=<%= @line_item.id %>] > .last_fulfillment").html("<%= format_date(@line_item.last_fulfillment) %>")
  $("#new_line_item_<%= @line_item.id %>_fulfillment").before("<%= escape_javascript(render(:partial =>'study_level_activities/fulfillment', locals: {fulfillment: @fulfillment})) %>")
  $(".selectpicker").selectpicker()
  $("#flashes_container").html("<%= escape_javascript(render('flash')) %>")
  $("#modal_place").modal 'hide'
