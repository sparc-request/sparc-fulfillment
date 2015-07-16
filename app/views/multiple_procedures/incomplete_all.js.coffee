<% if @note.errors.present? %>
$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @note.errors})) %>")
<% else %>

$(".core[data-core-id=#{core_id}] label.btn.incomplete").addClass('active')
$(".core[data-core-id=#{core_id}] .selectpicker.performed-by-dropdown").selectpicker('val', "<%= escape_javascript(current_identity.id)")

<% end %>
