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

$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>")
<% unless @errors %>

<% @arm_hash.each do |arm_id, value| %>
end_of_core = $("#arm_<%= arm_id %>_end_of_core_<%= @service.sparc_core_id %>")
if end_of_core.length == 0
  $("#end_of_arm_<%= arm_id %>").before("<div id='arm_<%= arm_id %>_core_<%= @service.sparc_core_id %>' class='row core'><div class='col-xs-12'>Core: <%= @service.sparc_core_name %></div></div><div id='arm_<%= arm_id %>_end_of_core_<%= @service.sparc_core_id %>'></div>")
$("#arm_<%= arm_id %>_end_of_core_<%= @service.sparc_core_id %>").before("<%= escape_javascript(render(:partial =>'study_schedule/line_item', locals: {line_item: value[:line_item], page: value[:page], tab: @schedule_tab})) %>")
<% end %>

$('div.study_schedule_container [data-toggle="tooltip"]').tooltip()
$(".selectpicker").selectpicker()
$("#modalContainer").modal 'hide'
$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");

<% end %>