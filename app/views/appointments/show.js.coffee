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

$('#appointmentsList').replaceWith("<%= j render 'protocols_participants/appointments', protocols_participant: @appointment.protocols_participant, appointment: @appointment %>")
$('#appointmentLoadingContainer').addClass('d-none')
$('#appointmentContainer').html("<%= j render '/appointments/calendar', appointment: @appointment, appointment_style: @appointment_style %>")

# TODO: remove this if render option works out
# pg = new ProcedureGrouper()

<% if @appointment_style == "grouped" %>
# pg.initialize()
<% else %>
# $("select.core_multiselect").multiselect(includeSelectAllOption: true, numberDisplayed: 1, nonSelectedText: 'Please Select')
# pg.initialize_multiselects_only()
<% end %>

$(".followup_procedure_datepicker").datetimepicker
  format: 'MM/DD/YYYY'
  ignoreReadonly: true

$(".completed_date_field").datetimepicker
  format: 'MM/DD/YYYY'
  ignoreReadonly: true

$('.row.appointment [data-toggle="tooltip"]').tooltip()

<% if @refresh_dashboard %>
$('table#completed-appointments-table').bootstrapTable('refresh', {url: "/appointments/completed_appointments.json?protocols_participant_id=<%= @appointment.protocols_participant_id %>", silent: "true"})
<% end %>

$('input#invoiced_procedure').bootstrapToggle()
$('input#credited_procedure').bootstrapToggle()

$(document).trigger('ajax:complete') # rails-ujs element replacement bug fix
