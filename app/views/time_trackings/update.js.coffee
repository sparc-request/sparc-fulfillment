$("#modal_errors").html("<%= j render 'modal_errors', errors: @errors %>")

<% unless @errors %>
$('#modalContainer').modal('hide')
$('#timeTrackingsTable').bootstrapTable('refresh')
<% end %>
