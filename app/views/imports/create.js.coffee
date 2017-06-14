<% if @valid %>
$('#modal_place').modal('hide')
$('.imports').bootstrapTable('refresh')
swal('Success', 'Klok File Uploaded', 'success')
<% else %>
$('.imports').bootstrapTable('refresh')
swal('Error', 'Invalid Klok File', 'error')
<% end %>
