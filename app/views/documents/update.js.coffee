<% if @errors.nil? %>
$("#modal_place").modal 'hide'
$("#documents_table").bootstrapTable 'refresh'
$("#reports_table").bootstrapTable 'refresh'
<% else %>
$("#document_modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>")
<% end %>
