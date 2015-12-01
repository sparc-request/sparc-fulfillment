$('#modal_place').modal('hide')

<% if @document.participant_report? %>
$("#participant_report_<%= @report_params[:participant_id] %>").data("document_id", "<%= @document.id %>")
$("#participant_report_<%= @report_params[:participant_id] %>").attr("document_id", "<%= @document.id %>")
<% elsif @document.study_schedule_report? %>
$("#study_schedule_report_<%= @report_params[:protocol_id] %>").data("document_id", "<%= @document.id %>")
$("#study_schedule_report_<%= @report_params[:protocol_id] %>").attr("document_id", "<%= @document.id %>")
<% end %>

$('table.documents').bootstrapTable('refresh')
