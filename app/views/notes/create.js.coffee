$("#modal_area").html("<%= escape_javascript(render(partial: 'index', locals: { notable: @notable, notes: @notes, notable_id: @notable_id, notable_type: @notable_type })) %>")
$("span#<%= @selector %>").html("<%= escape_javascript(@notes.count.to_s) %>")
