$("#modal_area").html("<%= escape_javascript(render(:partial =>'service_calendar/study_schedule/line_item_form', locals: {header_text: 'Remove Services', button_text: 'Remove', services: @services, protocol: @protocol, selected_service: @selected_service, page_hash: @page_hash, calendar_tab: @calendar_tab})) %>");
$("#modal_place").modal 'show'
change_service $('#service_id').val()
$(".selectpicker").selectpicker()