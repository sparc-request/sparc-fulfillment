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

<% if @otf %> # study level activities line item edit
$('.popover').popover('hide')
if !$(".line-item-<%= @line_item.id %>-<%= @field %>-popover").length
  $(".edit-<%= @field %>-<%= @line_item.id %>").popover(
    title:      "#{I18n.t('actions.edit')} <%= LineItem.human_attribute_name(@field) %> <a href='#' class='close' data-dismiss='alert'>&times;</a>"
    content:    $("<%= j render 'form', line_item: @line_item, field: @field %>")
    template:   '<div class="popover line-itme-popover line-item-<%= @line_item.id %>-<%= @field %>-popover" role="tooltip"><div class="arrow"></div><h3 class="popover-header"></h3><div class="popover-body"></div></div>'
    html:       true
    trigger:    'manual'
    placement:  'top'
    boundary:   'window'
  ).popover('show')
<% else %> # study schedule line item edit
$("#modalContainer").html("<%= escape_javascript(render(:partial =>'study_schedule/management/manage_services/change_service_form', locals: {line_item: @line_item})) %>")
$("#modalContainer").modal 'show'
<% end %>
