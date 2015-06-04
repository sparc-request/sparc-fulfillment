<% if @visit_group.errors[:name].any? %>
error_tooltip_on("#visit_group_<%= @visit_group.id %>", "Name <%= raw(@visit_group.errors[:name][0]) %>")
<% end %>
