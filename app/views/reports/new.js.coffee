$('#modal_area').html("<%= escape_javascript(render(partial: 'form', locals: { report: @report })) %>")
$('#modal_place').modal('show')
$('.datepicker').datetimepicker(format: 'MM-DD-YYYY')
$('.modal-content .selectpicker').selectpicker()
