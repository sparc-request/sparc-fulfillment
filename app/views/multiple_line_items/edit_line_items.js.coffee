$("#modal_area").html("<%= escape_javascript(render(:partial =>'study_schedule/management/manage_services/remove_line_items_form', locals: {arm_ids: @arm_ids, services: @services, protocol: @protocol, page_hash: @page_hash, schedule_tab: @schedule_tab})) %>");
$("#modal_place").modal 'show'
change_service $('#service_id').val()
$(".selectpicker").selectpicker()
