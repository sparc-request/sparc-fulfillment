$("#modalPlace").html("<%= escape_javascript(render(:partial =>'participants/participant_form', locals: {protocol: @protocol, participant: @participant, header_text: 'Create New Participant'})) %>");
