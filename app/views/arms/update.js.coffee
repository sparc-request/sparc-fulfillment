$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>")
<% unless @errors %>
$("#flashes_container").html("<%= escape_javascript(render('flash')) %>")
$("#modal_place").modal 'hide'
edit_arm_name("<%= @arm.name %>", "<%= @arm.id %>")
<% end %>
