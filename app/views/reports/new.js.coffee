$("#modal_area").html("<%= escape_javascript(render(partial: @report_type, locals: { title: @title, report_type: @report_type })) %>")
$("#modal_place").modal('show')
$('#start_date').datetimepicker(format: 'MM-DD-YYYY')
$('#end_date').datetimepicker(format: 'MM-DD-YYYY')
$(".modal-content .selectpicker").selectpicker()
$("select#organization_select").multiselect({
  includeSelectAllOption: true,
  enableFiltering: true,
  disableIfEmpty: true,
})


update_organization_dropdown = (org_ids) ->
  data = org_ids: org_ids
  $.ajax
    url: '/reports/update_dropdown'
    data: data

$ ->

  $('select#organization_select').on 'change', ->
    
    console.log($(this).val())
    $('#protocol_section').closest('.form-group').hide() 

    update_organization_dropdown($(this).val())
