# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

<% if @note && @note.errors.present? %>

$('#modal_errors').html("<%= escape_javascript(render(partial: 'modal_errors', locals: { errors: @note.errors })) %>")
$('#incomplete_all_modal button.save').removeClass('disabled')

<% else %>

$('#complete_all_modal button.save').removeClass('disabled')

<% if @procedures.present? %>

update_complete_visit_button(<%= @procedures.first.appointment.can_finish? %>)

<% @procedures.each do |procedure| %>

<% if procedure.incomplete? %>

$("tr.procedure[data-id='<%= procedure.id %>'] td.status .incomplete").addClass('active')
$("tr.procedure[data-id='<%= procedure.id %>'] td.status .complete").removeClass('active')
$("tr.procedure[data-id='<%= procedure.id %>'] .completed_date_field").val("").prop('disabled', true)
$("tr.procedure[data-id='<%= procedure.id %>'] td.performed-by .selectpicker").selectpicker('val', "<%= @performed_by %>")
<% if procedure.notes.any? %>
$('#modal_place').modal 'hide'
<% end %>

<% elsif procedure.complete? %>
$("tr.procedure[data-id='<%= procedure.id %>'] td.status .complete").addClass('active')
$("tr.procedure[data-id='<%= procedure.id %>'] td.status .incomplete").removeClass('active')
$("tr.procedure[data-id='<%= procedure.id %>'] .completed-date .completed_date_field.datetimepicker").val("<%= @completed_date %>").removeAttr("disabled")
$("tr.procedure[data-id='<%= procedure.id %>'] td.performed-by .selectpicker").selectpicker('val', "<%= @performed_by %>")
<% if procedure.notes.any? %>
$("#modal_place").modal('hide')
<% end %>
<% end %>
<% end %>
<% end %>
<% end %>

