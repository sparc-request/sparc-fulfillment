<% if @errors.nil? %>
window.document_id = <%= @document.id %>

$("#modal_place").modal('hide')
$('table.documents').bootstrapTable('refresh')
<% else %>
$(".modal #modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>")
<% end %>
