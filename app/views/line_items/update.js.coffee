$("#modal_errors").html("<%= escape_javascript(render(:partial =>'shared/modal_errors', locals: {errors: @errors})) %>");
if $("#modal_errors > .alert.alert-danger > p").length == 0
  <% if @otf %> # study level activities line item update
  $(".line_item[data-id=<%= @line_item.id %>]").replaceWith("<%= escape_javascript(render(:partial =>'study_level_activities/one_time_fee', locals: {line_item: @line_item})) %>")
  <% else %> # study schedule line item update
  $("#line_item_<%= @line_item.id %> .line_item_service_name").text("<%= @line_item.service.name %>")
  <% end %>
  $(".selectpicker").selectpicker()
  $("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
  $("#modal_place").modal 'hide'
  