$("#doc_modal_errors").html("<%= escape_javascript(render(:partial =>'shared/modal_errors', locals: {errors: @errors})) %>")
if $("#doc_modal_errors > .alert.alert-danger > p").length == 0
	$("#modal_place").modal 'hide'
