<% if @error.present? %>
$('#doc_modal_errors').empty().append("<div class='alert alert-danger'><%= @error %></div>")
<% else %>
$('.modal').modal('hide')
<% end %>
