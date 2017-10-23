# Copyright © 2011-2017 MUSC Foundation for Research Development~
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

$(document).on 'click', "#incomplete_all_modal button.save", (e) ->
  if !$('#incomplete_all_modal .performed-by-dropdown').val() || $('.reason-select .selectpicker .selected').index() == 0
    e.preventDefault()
    $('#multiple_procedures_modal_errors').addClass('alert').addClass('alert-danger').html('Please complete the required fields:')
  else
    $(this).addClass("disabled")

<% if @procedure.errors.present? %>
$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @procedure.errors})) %>")
<% else %>

update_complete_visit_button(<%= @procedure.appointment.can_finish? %>)

date_time_picker = $(".procedure[data-id='<%= @procedure.id %>']").find(".completed_date_field").datetimepicker(format: 'MM/DD/YYYY').data("DateTimePicker")

$("table.procedures tbody tr[data-id='<%= @procedure.id %>']").data('billing-type', "<%= @procedure.billing_type %>").attr('data-billing-type', "<%= @procedure.billing_type %>")
$("table.procedures tbody tr[data-id='<%= @procedure.id %>']").data('group-id', "<%= @procedure.group_id %>").attr('data-group-id', "<%= @procedure.group_id %>")

<% if @procedure.unstarted? || @procedure.follow_up? %>
date_time_picker.date(null).disable()
$(".procedure[data-id='<%= @procedure.id %>']").find(".status label.active").removeClass("active")
$("table.procedures tbody tr[data-id='<%= @procedure.id %>'] td.performed-by .selectpicker").selectpicker('val', "")

<% elsif @procedure.incomplete? %>
date_time_picker.date(null).disable()

$("table.procedures tbody tr[data-id='<%= @procedure.id %>'] td.performed-by .selectpicker").selectpicker('val', '<%= @procedure.performer_id %>')

<% elsif @procedure.complete? %>
date_time_picker.date("<%= format_date(@procedure.completed_date) %>").enable()

$("table.procedures tbody tr[data-id='<%= @procedure.id %>'] td.performed-by .selectpicker").selectpicker('val', '<%= @procedure.performer_id %>')

<% end %>

$('.appointments').html("<%= escape_javascript(render(partial: '/appointments/calendar', locals: { appointment: @appointment })) %>")

pg = new ProcedureGrouper()
pg.initialize()

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

$('#appointment_indications').selectpicker()
$('#appointment_indications').selectpicker('val', statuses)

$(".followup_procedure_datepicker").datetimepicker
  format: 'MM/DD/YYYY'
  ignoreReadonly: true

$(".completed_date_field").datetimepicker
  format: 'MM/DD/YYYY'
  ignoreReadonly: true

$('.row.appointment [data-toggle="tooltip"]').tooltip()

$("#group-<%= @procedure.group_id %> button").trigger('click')
$("#modal_place").modal 'hide'
<% end %>
