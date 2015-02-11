$("#participant_calendar").html("<%= escape_javascript(render(:partial =>'participant_calendar/_calendar', locals: {protocol: @protocol, participant: @participant, appointment: @appointment})) %>");
