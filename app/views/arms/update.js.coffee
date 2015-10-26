$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>")
<% unless @errors %>
$("#flashes_container").html("<%= escape_javascript(render('flash')) %>")
$("#modal_place").modal 'hide'
$("#arm-name-display-<%= @arm.id %>").html("<%= @arm.name %>")
<% end %>
