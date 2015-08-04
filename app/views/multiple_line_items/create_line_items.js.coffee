$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>")
<% unless @errors %>

<% @arm_hash.each do |arm_id, value| %>
end_of_core = $("#arm_<%= arm_id %>_end_of_core_<%= @service.sparc_core_id %>")
if end_of_core.length == 0
  $("#end_of_arm_<%= arm_id %>").before("<div id='arm_<%= arm_id %>_core_<%= @service.sparc_core_id %>' class='row core'><div class='col-xs-12'>Core: <%= @service.sparc_core_name %></div></div><div id='arm_<%= arm_id %>_end_of_core_<%= @service.sparc_core_id %>'></div>")
$("#arm_<%= arm_id %>_end_of_core_<%= @service.sparc_core_id %>").before("<%= escape_javascript(render(:partial =>'study_schedule/line_item', locals: {line_item: value[:line_item], page: value[:page], tab: @schedule_tab})) %>")
<% end %>

$('div.study_schedule_container [data-toggle="tooltip"]').tooltip()
$(".selectpicker").selectpicker()
$("#modal_place").modal 'hide'
$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");

<% end %>