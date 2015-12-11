$('#modal_place').modal('hide')

<% if @document.participant_report? %>
$("#participant_report_<%= @report_params[:participant_id] %>").data('document_id', "<%= @document.id %>")
<% elsif @document.study_schedule_report? %>
$("#study_schedule_report_<%= @report_params[:protocol_id] %>").data('document_id', "<%= @document.id %>")
<% else %>
$('table.documents').bootstrapTable('refresh', { slient: true })
<% end %>
