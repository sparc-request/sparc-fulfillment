$("#modal_area").html("<%= escape_javascript(render(partial: 'index', locals: { notable: @notable, notes: @notes, notable_id: @notable_id, notable_type: @notable_type })) %>")
unless $("span#<%= @selector %>.glyphicon").hasClass("blue-notes")
  $("span#<%= @selector %>.glyphicon").addClass("blue-notes")
