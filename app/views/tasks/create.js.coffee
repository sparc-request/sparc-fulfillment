<% if @errors.present? %>
$("#modal_errors").html("<%= escape_javascript(render(:partial =>'shared/modal_errors', locals: {errors: @errors})) %>")
<% else %>
$(".notification.task-notifications").empty().append("<%= current_user.reload.tasks_count %>")
$("#flashes_container").html("<%= escape_javascript(render('flash')) %>")
$('#task-list').bootstrapTable('refresh', {url: "/tasks.json", silent: "true"})
$("#modal_place").modal 'hide'
<% if @procedure.present? %>
$("#follow_up_<%= @procedure.id %>").html("<%= escape_javascript(render(:partial =>'appointments/followup_calendar', locals: {procedure: @procedure})) %>")
<% end %>
$("#followup_procedure_datepicker").datetimepicker(format: 'MM-DD-YYYY')
<% end %>

