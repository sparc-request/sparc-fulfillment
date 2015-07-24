$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @report.errors})) %>");
if $("#modal_errors > .alert.alert-danger > p").length == 0
  window.document_id = <%= @document.id %>
  $("#modal_place").modal('hide')
  $('table.documents').bootstrapTable('refresh')