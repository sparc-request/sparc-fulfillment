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

<% if @errors %>
$("[name^='task']:not([type='hidden'])").parents('.form-group').removeClass('is-invalid').addClass('is-valid')
$('.form-error').remove()
<% @errors.messages.each do |attr, messages| %>
<% messages.each do |message| %>
$("[name='task[<%= attr.to_s %>]']").parents('.form-group').removeClass('is-valid').addClass('is-invalid').append("<small class='form-text form-error'><%= message.capitalize.html_safe %></small>")
<% end %>
<% end %>
<% else %>
$("nav#siteNav").replaceWith("<%= j render 'layouts/navbar' %>")
$("#tasks").bootstrapTable('refresh')
$("#flashContainer").replaceWith("<%= j render 'layouts/flash' %>")
$("#modalContainer").modal('hide')
<% end %>

# JS related to appointments and procedures, this will be refactored later

<% if @procedure.present? %>
$("#followup<%= @procedure.id %>").replaceWith("<%= j render 'procedures/followup', procedure: @procedure %>")
updateNotesBadge("procedure<%= @procedure.id %>", "<%= format_count(@procedure.notes.length) %>")
<% end %>

<% if @appointment.present? %>
$('.appointments').html("<%= j render 'appointments/calendar', appointment: @appointment, appointment_style: @appointment_style %>")

if !$('.start_date_input').hasClass('hidden')
  start_date_init("<%= format_datetime(@appointment.start_date) %>")

if !$('.completed_date_input').hasClass('hidden')
  completed_date_init("<%= format_datetime(@appointment.completed_date) %>")

$('#appointment_content_indications').selectpicker()
$('#appointment_content_indications').selectpicker('val', "<%= @appointment.contents %>")
$(".selectpicker").selectpicker()

statuses = []
<% @statuses.each do |status| %>
statuses[statuses.length] =  "<%= status %>"
<% end %>

$(".followup_procedure_datepicker").datetimepicker
  format: 'MM/DD/YYYY'
  ignoreReadonly: true

$(".completed_date_field").datetimepicker(format: 'MM/DD/YYYY')

$('.row.appointment [data-toggle="tooltip"]').tooltip()
<% end %>

$(".followup_procedure_datepicker").datetimepicker(format: 'MM/DD/YYYY')
