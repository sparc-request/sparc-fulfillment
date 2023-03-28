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

<% if @errors %>
$("[name^='add_service_arm']:not([type='hidden'])").parents('.form-group').removeClass('is-invalid').addClass('is-valid')
$('.form-error').remove()
<% @errors.messages.each do |attr, messages| %>
<% messages.each do |message| %>
$("[name^='add_service_arm']").parents('.form-group').removeClass('is-valid').addClass('is-invalid').append("<small class='form-text form-error'><%= message.capitalize.html_safe %></small>")
<% end %>
<% end %>
<% elsif @first_line_item %>
$("#flashContainer").replaceWith("<%= j render 'layouts/flash' %>")
$('#protocolTabs').replaceWith("<%= j render 'protocols/tabs', protocol: @protocol, tab: @tab, has_pppv_services: @has_pppv_services %>")
$('#requestLoading').removeClass('active show')
$("#<%= @tab.camelize(:lower) %>Tab").html('<%= j render "protocols/#{@tab}", protocol: @protocol %>').addClass('active show')
$('div.study_schedule_container [data-toggle="tooltip"]').tooltip()
$(".selectpicker").selectpicker()
$("#modalContainer").modal 'hide'
<% else %>
<% @arm_hash.each do |arm_id, value| %>
core_header_row = $('.arm-<%= arm_id %>-container .core-header[data-core-id="<%= @core.id %>"]')
if core_header_row.length
  $('.arm-<%= arm_id %>-container .line-item[data-core-id="<%= @core.id %>"]').last().after("<%= j render 'study_schedule/line_item', line_item: value[:line_item], page: value[:page], tab: @schedule_tab, core_id: @core.id %>")
else
  last_line_item = $('.arm-<%= arm_id %>-container tr').last()
  last_line_item.after("<%= j render 'study_schedule/line_item', line_item: value[:line_item], page: value[:page], tab: @schedule_tab, core_id: @core.id %>")
  last_line_item.after("<%= j render 'study_schedule/core_header', core: @core %>")
<% end %>

$('div.study_schedule_container [data-toggle="tooltip"]').tooltip()
$(".selectpicker").selectpicker()
$("#flashContainer").replaceWith("<%= j render 'layouts/flash' %>")
$("#modalContainer").modal 'hide'
<% end %>
