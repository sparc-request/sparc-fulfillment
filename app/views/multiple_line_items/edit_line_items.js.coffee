$("#modal_area").html("<%= escape_javascript(render(:partial =>'study_schedule/management/manage_services/line_item_form', locals: {arm_ids: @arm_ids, header_text: 'Remove Services', button_text: 'Remove', services: @services, protocol: @protocol, page_hash: @page_hash, schedule_tab: @schedule_tab})) %>");
$("#modal_place").modal 'show'
change_service $('#service_id').val()
$(".selectpicker").selectpicker()
