if $("#end_of_core_<%= @core_id %>").length == 0
  $("#end_of_appointment_<%= @appointment_id %>").before("<div id='core_<%= @core_id %>' class='row core'><div class='col-xs-12'><%= @core_name %></div></div> <div id='end_of_core_<%= @core_id %>' class='hidden'>")

end_of_core = $("#end_of_core_<%= @core_id %>")
<% @procedures.each do |procedure| %>
end_of_core.before("<%= escape_javascript(render partial: 'appointments/procedure', locals: {procedure: procedure}) %>")
<% end %>