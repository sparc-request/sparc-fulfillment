<% if @note %>
$("#modal_area").html("<%= escape_javascript(render(partial: 'incomplete_all_modal', locals: {appointment_id: @appointment_id, core_id: @core_id, note: @note})) %>")
$("#modal_place").modal 'show'
<% else %>
##Complete all refactoring placeholder
<% end %>
