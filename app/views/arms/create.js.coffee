$("#arm_modal_errors").html("<%= escape_javascript(render(:partial =>'shared/modal_errors', locals: {errors: @errors})) %>");
<% if @errors.nil? %>
$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
$("#arm_modal").modal 'hide'
create_arm("<%= @arm.name %>", "<%= @arm.id %>");
$(".service_calendar_container").append("<%= escape_javascript(render(:partial =>'service_calendar/template', locals: {arm: @arm, page: 1})) %>");
<% end %>
