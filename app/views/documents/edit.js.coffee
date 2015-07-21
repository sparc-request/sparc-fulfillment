$("#modal_area").html("<%= escape_javascript(render(:partial =>'document_form', locals: {document: @document})) %>");
$("#modal_place").modal 'show'
