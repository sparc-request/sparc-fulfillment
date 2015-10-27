$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @report.errors})) %>");
if $("#modal_errors > .alert.alert-danger > p").length == 0
  <% if @reports_params %>
  <% if not @reports_params[:participant_id].blank? %>
  $("#participant_report_<%= @reports_params[:participant_id] %>").data("document_id", "<%= @document.id %>")
  $("#participant_report_<%= @reports_params[:participant_id] %>").attr("document_id", "<%= @document.id %>")
  <% elsif @document.documentable_type == 'Protocol' %>
  $("#study_schedule_report_<%= @reports_params[:protocol_id] %>").data("document_id", "<%= @document.id %>")
  $("#study_schedule_report_<%= @reports_params[:protocol_id] %>").attr("document_id", "<%= @document.id %>")
  <% end %>
  <% end %>
  window.document_id = <%= @document.id %>
  $("#modal_place").modal('hide')
  $('table.documents').bootstrapTable('refresh')
