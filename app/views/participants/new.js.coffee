$("#modalPlace").html("<%= escape_javascript(render(:partial =>'protocols/participant_form', locals: {protocol: @protocol, participant: @participant, header_text: 'Create New Participant'})) %>");
