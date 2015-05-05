$("#modal_errors").html("<%= escape_javascript(render(:partial =>'shared/modal_errors', locals: {errors: @errors})) %>");
if $("#modal_errors > .alert.alert-danger > p").length == 0
  $(".line_item[data-id=<%= @line_item.id %>] > .qty_rem").html("<%= @line_item.quantity_remaining %>")
  $(".line_item[data-id=<%= @line_item.id %>] > .last_fulfillment").html("<%= format_date(@line_item.last_fulfillment) %>")
  $(".fulfillment[data-id=<%= @fulfillment.id %>]").replaceWith("<%= escape_javascript(render(:partial =>'study_level_activities/fulfillment', locals: {fulfillment: @fulfillment})) %>")
  $(".fulfillment_component[data-id=<%= @fulfillment.component.id %>]").selectpicker()
  $("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
  $("#modal_place").modal 'hide'