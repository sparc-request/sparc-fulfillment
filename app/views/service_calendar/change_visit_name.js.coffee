reset_title = (selector) ->
  $(selector).val($(selector).attr('previous_name'))

save_title = (selector) ->
  $(selector).attr('previous_name', $(selector).val())

<% if @visit_group.errors[:name].any? %>
error_tooltip_on("#visit_group_<%= @visit_group.id %>", "Name <%= raw(@visit_group.errors[:name][0]) %>")
reset_title("#visit_group_<%= @visit_group.id %>")
<% else %>
save_title("#visit_group_<%= @visit_group.id %>")
<% end %>
