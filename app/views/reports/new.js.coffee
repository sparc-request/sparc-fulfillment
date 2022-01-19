# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

$("#modalContainer").html("<%= escape_javascript(render(partial: @report_type, locals: { title: @title, report_type: @report_type })) %>")
$("#modalContainer").modal('show')

$('#start_date').datetimepicker
  format: 'MM/DD/YYYY'
  ignoreReadonly: true
  allowInputToggle: false
  useCurrent: false

$('#end_date').datetimepicker
  format: 'MM/DD/YYYY'
  ignoreReadonly: true
  allowInputToggle: false
  useCurrent: false


if $("#protocol_section.background_load").length
  $.ajax
    type: 'GET'
    url: "reports/update_protocols_dropdown"
    data: { report_type: "<%= escape_javascript(@report_type) %>"}

$(".modal-content .selectpicker").selectpicker()

$(".modal-content #mrn_select").selectpicker({
  selectedTextFormat: 'count',
  countSelectedText: (selected, total) -> if (selected == total) then "All MRNs" else "#{selected} MRNs selected"
  actionsBox: true,
  liveSearch: true
})

# Change title based on service type selection
$(document).on 'change', '#service_type_select', ->
  if $(this).val() == "Clinical Services"
    $('input#title').val("Auditing Report (Clinical Services)")
  else
    $('input#title').val("Auditing Report (Non-clinical Services)")
