$("#modal_area").html("<%= escape_javascript(render(:partial =>'study_schedule/management/manage_services/add_line_items_form', locals: { services: @services, page_hash: @page_hash, schedule_tab: @schedule_tab })) %>");
$("#modal_place").modal 'show'
$(".selectpicker").selectpicker()
