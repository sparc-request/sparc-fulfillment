$(".appointment").html("<%= escape_javascript(render(partial: 'calendar', locals: { appointment: @appointment })) %>")

<% @appointment.procedures.each do |procedure| %>
$(".date#<%= dom_id(procedure) %>").datetimepicker(format: 'YYYY-MM-DD', defaultDate: "<%= format_date(procedure.follow_up_date) %>")
<% end %>
