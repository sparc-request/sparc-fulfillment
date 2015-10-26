$("#modal_area").html("<%= escape_javascript(render(:partial =>'study_schedule/management/manage_services/remove_line_items_form', locals: { arms: @arms, all_services: @all_services, service: @service, protocol: @protocol })) %>");
$("#modal_place").modal 'show'
$(".selectpicker").selectpicker()
