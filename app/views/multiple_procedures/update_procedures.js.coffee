# Copyright © 2011-2023 MUSC Foundation for Research Development~
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

<% if @multiple_procedure_errors %>
$("#completeIncompleteAll input:not([type='hidden'])").parents('.form-group').removeClass('is-invalid').addClass('is-valid')
$('.form-error').remove()
<% @multiple_procedure_errors.each do |attr, message| %>
$("#completeIncompleteAll [name='<%= attr.to_s %>']").parents('.form-group').removeClass('is-valid').addClass('is-invalid').append("<small class='form-text form-error'><%= message.capitalize.html_safe %></small>")
<% end %>

<% else %>

<% @procedures.each do |procedure| %>
$("#procedure<%= procedure.id %>StatusButtons button").removeClass('active')
$("#procedure<%= procedure.id %>StatusButtons").data('selected', '<%= procedure.status %>')
$("#procedure<%= procedure.id %>StatusButtons .<%= procedure.status %>-btn").addClass('active')
updateNotesBadge("procedure<%= procedure.id %>", "<%= procedure.notes.count %>")
$(".performer #edit_procedure_<%= procedure.id %> .selectpicker").selectpicker('val', '<%= procedure.performer_id %>')
date_time_picker = $("#procedure<%= procedure.id %>CompletedDatePicker")

invoiced_date_time_picker = $("#procedure<%= procedure.id %>InvoicedDatePicker")
invoiced_date_time_picker.datetimepicker('date', "<%= format_date(procedure.invoiced_date) %>")

invoiced_toggle = $(".invoiced #edit_procedure_<%= procedure.id %>")
credited_toggle = $(".credited #edit_procedure_<%= procedure.id %>")

<% if procedure.incomplete? %>
date_time_picker.datetimepicker('date', null)
date_time_picker.datetimepicker('disable')

invoiced_toggle.bootstrapToggle('disable')
invoiced_toggle.find('#procedure_invoiced').removeAttr('disabled')
credited_toggle.bootstrapToggle('disable')
credited_toggle.find('#procedure_credited').removeAttr('disabled')
$('.toggle-off').text('No')

<% elsif procedure.complete? %>
date_time_picker.datetimepicker('date', "<%= format_date(procedure.completed_date) %>")
date_time_picker.datetimepicker('enable')

invoiced_toggle.bootstrapToggle('enable')
invoiced_toggle.find('#procedure_invoiced').removeAttr('disabled')
credited_toggle.bootstrapToggle('enable')
credited_toggle.find('#procedure_credited').removeAttr('disabled')
$('.toggle-off').text('No')

<% end %>
<% end %>

<% if @appointment.can_finish? %>
$(".appointment-action-buttons").html("<%= j render '/appointments/appointment_action_buttons', appointment: @appointment %>")
<% end %>

$('#modalContainer').modal('hide')

<% end %>

$(document).trigger('ajax:complete') # rails-ujs element replacement bug fix
