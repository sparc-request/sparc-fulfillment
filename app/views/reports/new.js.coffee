# Copyright © 2011-2018 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

$("#modal_area").html("<%= escape_javascript(render(partial: @report_type, locals: { title: @title, report_type: @report_type })) %>")
$("#modal_place").modal('show')

$('#start_date').datetimepicker
  format: 'MM/DD/YYYY'
  ignoreReadonly: true

$('#end_date').datetimepicker
  format: 'MM/DD/YYYY'
  ignoreReadonly: true

if $("#protocol_section.background_load").length
  $.ajax
    type: 'GET'
    url: "reports/update_protocols_dropdown"
    data: { report_type: "<%= escape_javascript(@report_type) %>"}

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
      $('#protocol_section').append("<i class='dropdown-glyphicon glyphicon glyphicon-refresh spin' />")
      $('#protocol_section').closest('.form-group').removeClass("hidden")
      $.ajax
        type: 'GET'
        url: "reports/update_protocols_dropdown"
        data: { org_ids: multi_select.val() }
})

# Hide protocols dropdown if an Organization has not been selected
$(document).on 'change', "#organization_select", ->
  if $(this).val() == null
    $('#protocol_section').closest('.form-group').addClass("hidden")
    $('#protocol_section').empty()

# Change title based on service type selection
$(document).on 'change', '#service_type_select', ->
  if $(this).val() == "Clinical Services"
    $('input#title').val("Auditing Report (Clinical Services)")
  else
    $('input#title').val("Auditing Report (Non-clinical Services)")
