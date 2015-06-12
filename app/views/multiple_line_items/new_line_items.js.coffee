$("#modal_area").html("<%= escape_javascript(render(:partial =>'study_schedule/study_schedule_management/line_item_form', locals: {header_text: 'Add a Service', button_text: 'Add Service', services: @services, protocol: @protocol, selected_service: @selected_service, page_hash: @page_hash, schedule_tab: @schedule_tab})) %>");
$("#modal_place").modal 'show'
$(".selectpicker").selectpicker()