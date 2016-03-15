$("#modal_area").html("<%= escape_javascript(render(partial: @report_type, locals: { title: @title, report_type: @report_type })) %>")
$("#modal_place").modal('show')
$('#start_date').datetimepicker(format: 'MM-DD-YYYY')
$('#end_date').datetimepicker(format: 'MM-DD-YYYY')
$(".modal-content .selectpicker").selectpicker()
multi_select = $("#organization_select")
multi_select.multiselect({
  numberDisplayed: 2,
  includeSelectAllOption: true,
  enableFiltering: true,
  disableIfEmpty: true,
  enableClickableOptGroups: true,
  buttonWidth: '100%',
  onDropdownShow: (e) ->
    if multi_select.val() == null
      @original_selected_values = []
    else
      @original_selected_values = multi_select.val()
  onDropdownHide: (e) ->
    selected_values = multi_select.val()
    if !_.isEqual(@original_selected_values,selected_values) && selected_values != null
      $('#protocol_section').empty() 
      $('#protocol_section').closest('.form-group').find('label').append("<i class='dropdown-glyphicon glyphicon glyphicon-refresh spin' />")
      $('#protocol_section').closest('.form-group').show()
      $.ajax
        type: 'POST'
        url: '/reports/update_dropdown'
        data: { org_ids: multi_select.val() }
    else
      $('#protocol_section').closest('.form-group').hide()
})
