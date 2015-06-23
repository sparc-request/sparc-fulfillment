window.document_id = <%= @document.id %>

$("#modal_place").modal('hide');
$('table.documents').bootstrapTable('refresh')
