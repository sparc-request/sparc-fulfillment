$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
$("#modal_place").modal 'hide'
edit_visit_group("<%= @visit_group.name %>", "<%= @visit_group.id %>");
$(".service_calendar_container").replaceWith("<%= escape_javascript(render(:partial =>'service_calendar/template', locals: {arm: @arm, page: 1})) %>");