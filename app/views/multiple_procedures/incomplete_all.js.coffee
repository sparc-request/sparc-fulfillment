<% if @note.errors.present? %>
$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @note.errors})) %>")
<% else %>

$(".core[data-core-id='<%= @core_id %>'] td.status label.btn").removeClass('active')
$(".core[data-core-id='<%= @core_id %>'] td.status .incomplete").addClass('active')
$(".core[data-core-id='<%= @core_id %>'] .selectpicker.performed-by-dropdown").selectpicker('val', "<%= current_identity.id %>")

$("#modal_place").modal 'hide'
<% end %>
