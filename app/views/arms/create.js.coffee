$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>")
<% unless @errors %>
$("#flashes_container").html("<%= escape_javascript(render('flash')) %>")
$("#modal_place").modal 'hide'
$(".study_schedule_container").append("<%= escape_javascript(render(partial: 'study_schedule/arm', locals: {arm: @arm, page: 1, tab: @schedule_tab})) %>")
$('div.study_schedule_container [data-toggle="tooltip"]').tooltip()
<% end %>
