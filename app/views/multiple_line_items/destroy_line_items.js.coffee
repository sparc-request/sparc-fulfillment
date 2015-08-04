$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>")
<% unless @errors %>

<% @line_item_ids.each do |li_id| %>
$("#line_item_<%= li_id %>").remove()
<% end %>
<% @arm_ids.each do |arm_id| %>
core_header = $("#arm_<%= arm_id %>_core_<%= @service.sparc_core_id %>")
if core_header.next().attr('id') == "arm_<%= arm_id %>_end_of_core_<%= @service.sparc_core_id %>"
  $("#arm_<%= arm_id %>_end_of_core_<%= @service.sparc_core_id %>").remove()
  core_header.remove()
<% end %>
$("#modal_place").modal 'hide'
$("#flashes_container").html("<%= escape_javascript(render('flash')) %>")

<% end %>