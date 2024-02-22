$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>")
<% unless @errors %>
$('#flashContainer').html("<%= escape_javascript(render('flash')) %>")
<% end %>
