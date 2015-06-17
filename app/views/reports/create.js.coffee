$("#modal_place").modal('hide');
$('table.documents').bootstrapTable('refresh')

$notification           = $('.notification.document-notifications')
documents_notifications = parseInt $notification.text()

$notification.empty().text(documents_notifications + 1)
