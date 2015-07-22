$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @report.errors})) %>");
if $("#modal_errors > .alert.alert-danger > p").length == 0
  <% if not @reports_params[:participant_id].blank? %>
  $("#participant_report_<%= @reports_params[:participant_id] %>").attr('data-document_id', '<%= @document.id %>')
  <% elsif @document.documentable_type == 'Protocol' %>
  $(".study_schedule_report").attr('data-document_id', '<%= @document.id %>')
  <% end %>
  window.document_id = <%= @document.id %>
  $("#modal_place").modal('hide')
  $('table.documents').bootstrapTable('refresh')
