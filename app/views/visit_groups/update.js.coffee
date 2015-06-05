$("#modal_errors").html("<%= escape_javascript(render(:partial =>'shared/modal_errors', locals: {errors: @errors})) %>");
<% unless @errors %>
$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
$("#modal_place").modal 'hide'
edit_visit_group_name("<%= @visit_group.name %>", "<%= @visit_group.id %>");
$("#visit-before-display-<%= @visit_group.id %>").html("<%= @visit_group.window_before %>")
$("#visit-after-display-<%= @visit_group.id %>").html("<%= @visit_group.window_after %>")
$("#visit-day-display-<%= @visit_group.id %>").html("<%= @visit_group.day %>")
<% end %>