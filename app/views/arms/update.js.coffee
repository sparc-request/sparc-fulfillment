$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
$("#modal_place").modal 'hide'
edit_arm("<%= @arm.name %>", "<%= @arm.id %>");
$(".service_calendar_container").replaceWith("<%= escape_javascript(render(:partial =>'service_calendar/template', locals: {arm: @arm, page: 1})) %>");