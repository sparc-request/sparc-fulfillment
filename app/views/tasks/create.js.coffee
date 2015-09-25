<% if @errors.present? %>
$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>")
<% else %>
if !$('.notification.task-notifications').length
  $('<span class="notification task-notifications"></span>').appendTo($('a.tasks'))
$(".notification.task-notifications").empty().append("<%= current_identity.reload.tasks_count %>")
$("#flashes_container").html("<%= escape_javascript(render('flash')) %>")
$('#task-list').bootstrapTable('refresh', {silent: "true"})
$("#modal_place").modal 'hide'
<% if @procedure.present? %>
$("#follow_up_<%= @procedure.id %>").html("<%= escape_javascript(render(:partial =>'appointments/followup_calendar', locals: {procedure: @procedure})) %>")
update_complete_visit_button(<%= @procedure.appointment.can_finish? %>)
<% end %>
$(".followup_procedure_datepicker").datetimepicker(format: 'MM-DD-YYYY')
<% end %>
