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
$("[name^='procedure']:not([type='hidden'])").parents('.form-group').removeClass('is-invalid').addClass('is-valid')
$('.form-error').remove()

<% @errors.messages.each do |attr, messages| %>
<% messages.each do |message| %>
$("[name='procedure[<%= attr.to_s %>]']").parents('.form-group').removeClass('is-valid').addClass('is-invalid').append("<small class='form-text form-error'><%= message.capitalize.html_safe %></small>")
<% end %>
<% end %>

<% @procedure.notes.last.errors.messages.each do |attr, messages| %>
<% messages.each do |message| %>
$("[name='procedure[notes_attributes][0][<%= attr.to_s %>]']").parents('.form-group').removeClass('is-valid').addClass('is-invalid').append("<small class='form-text form-error'><%= message.capitalize.html_safe %></small>")
<% end %>
<% end %>
<% else %>
$("#core-<%= @procedure.sparc_core_id %>-procedures").bootstrapTable('refresh', silent: true)
$("#modalContainer").modal('hide')

date_time_picker = $("#procedure<%= @procedure.id %>CompletedDatePicker")
performer_selectpicker = $(".performer #edit_procedure_<%= @procedure.id %> .selectpicker")
date_time_picker.datetimepicker('format', 'MM/DD/YYYY')

<% if @procedure.unstarted? || @procedure.follow_up? %>
date_time_picker.datetimepicker('date', null)
date_time_picker.datetimepicker('disable')
$(".procedure[data-id='<%= @procedure.id %>']").find(".status label.active").removeClass("active")
performer_selectpicker.selectpicker('val', "")

<% elsif @procedure.incomplete? %>
date_time_picker.datetimepicker('date', null)
date_time_picker.datetimepicker('disable')
$("#procedure<%= @procedure.id %>StatusButtons").data("selected", "incomplete")
$("#procedure<%= @procedure.id %>StatusButtons button").removeClass("active")
$("#procedure<%= @procedure.id %>StatusButtons .incomplete-btn").addClass("active")
performer_selectpicker.selectpicker('val', '<%= @procedure.performer_id %>')

<% elsif @procedure.complete? %>
date_time_picker.datetimepicker('date', "<%= format_date(@procedure.completed_date) %>")
date_time_picker.datetimepicker('enable')
performer_selectpicker.selectpicker('val', '<%= @procedure.performer_id %>')

<% end %>

<% if (@billing_type_updated && @appointment_style == "grouped") || @invoiced_or_credited_changed %>
$('#core<%= @procedure.core.id %>ProceduresGroupedView').bootstrapTable('refresh', silent: true)
<% end %>

<% if @billing_type_updated %>
<% core_id = @procedure.sparc_core_id %>
select_container = $("select.core_multiselect[data-core-id='<%= core_id %>']").parents('.service-multiselect-container')
select_container.replaceWith("<%= j render '/multiple_procedures/complete_all_select', appointment: @appointment, core_id: core_id, procedures: @appointment.procedures_grouped_by_core[core_id] %>")
<% end %>

statuses = []
<% @statuses.each do |status| %>
statuses[statuses.length] =  "<%= status %>"
<% end %>

$(".appointment-action-buttons").html("<%= j render '/appointments/appointment_action_buttons', appointment: @appointment %>")

$("#group-<%= @procedure.group_id %> button").trigger('click')

updateNotesBadge("procedure<%= @procedure.id %>", "<%= @procedure.notes.count %>")

<% if @cost_error_message %>
Swal.fire("<%= @cost_error_message %>")
<% end %>
<% end %>

$(document).trigger('ajax:complete') # rails-ujs element replacement bug fix
