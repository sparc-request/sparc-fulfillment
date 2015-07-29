$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @arm.errors})) %>")
<% unless @errors %>
$(".study_schedule.service.arm_#{arm_id}").remove()
$("#flashes_container").html("<%= escape_javascript(render('application/flash')) %>")
$("#modal_place").modal 'hide'
<% end %>
