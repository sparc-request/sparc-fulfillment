$("#modal_area").html("<%= escape_javascript(render(partial: @report_type, locals: { title: @title, report_type: @report_type })) %>")
$("#modal_place").modal('show')

$('#start_date').datetimepicker
  format: 'MM/DD/YYYY'
  ignoreReadonly: true

$('#end_date').datetimepicker
  format: 'MM/DD/YYYY'
  ignoreReadonly: true

$(".modal-content .selectpicker").selectpicker()

multi_select = $("#organization_select")
multi_select.multiselect({
  numberDisplayed: 2,
  includeSelectAllOption: true,
  allSelectedText: "All Organizations",
  nonSelectedText: 'Select Organization(s)',
  enableFiltering: true,
  disableIfEmpty: true,
  enableClickableOptGroups: true,
  buttonWidth: '100%',
  onDropdownShow: (e) ->
    # If user does not select an organization, 
    # set @original_selected_values to an empty array
    # else set to selected organizations
    if multi_select.val() == null
      @original_selected_values = []
    else
      @original_selected_values = multi_select.val()
  onDropdownHide: (e) ->
    selected_values = multi_select.val()
    if !_.isEqual(@original_selected_values,selected_values) && selected_values != null
      $('#protocol_section').empty()
      $('#protocol_section').closest('.form-group').find('label').append("<i class='dropdown-glyphicon glyphicon glyphicon-refresh spin' />")
      $('#protocol_section').closest('.form-group').removeClass("hidden")
      $.ajax
        type: 'POST'
        url: "reports/update_dropdown"
        data: { org_ids: multi_select.val() }
})

# Hide protocols dropdown if an Organization has not been selected
$(document).on 'change', "#organization_select", ->
  if $(this).val() == null
    $('#protocol_section').closest('.form-group').addClass("hidden")
    $('#protocol_section').empty()
