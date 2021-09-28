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
$("[name^='visit_group']:not([type='hidden'])").parents('.form-group').removeClass('is-invalid').addClass('is-valid')
$('.form-error').remove()
<% @errors.messages.each do |attr, messages| %>
<% messages.each do |message| %>
$("[name='visit_group[<%= attr.to_s %>]']").parents('.form-group').removeClass('is-valid').addClass('is-invalid').append("<small class='form-text form-error'><%= message.capitalize.html_safe %></small>")
<% end %>
<% end %>
<% else %>
$("#flashContainer").replaceWith("<%= j render 'layouts/flash' %>")
$("#modalContainer").modal 'hide'

# update dropdown to page visit groups
arm_id = <%= @arm.id %>
tab = $('#current_tab').val()
$("#select_for_arm_#{arm_id}").replaceWith("<%= j render '/study_schedule/visit_group_page_select', arm: @arm, page: @current_page.to_i %>")
$(".selectpicker").selectpicker()


# on_current_page? checks if the visit_group should be on the current page after update, also need to check if it's there before it was updated
if <%= on_current_page?(@current_page, @visit_group.position) %> || $('#visit-name-display-<%= @visit_group.id %>').length
  # Overwrite the visit_groups
  $(".visit_groups_for_#{arm_id}").html("<%= j render '/study_schedule/visit_groups', arm: @arm, visit_groups: @visit_groups, tab: @schedule_tab %>")
  # Overwrite the check columns
  $(".check_columns_for_arm_#{arm_id}").html("<%= j render '/study_schedule/check_visit_columns', visit_groups: @visit_groups, tab: @schedule_tab %>")
  # Overwrite the visits
  <% @arm.line_items.each do |line_item| %>
  $(".visit_for_line_item_<%= line_item.id %>").last().after('<div id="placeholderElement"></div>')
  placeholder_element = $('#placeholderElement')
  placeholder_element.siblings('.visit').remove()
  placeholder_element.after("<%= j render '/study_schedule/visits', line_item: line_item, page: @current_page.to_i, tab: @schedule_tab %>")
  placeholder_element.remove()
  <% end %>
  #Adjust sticky headers
  adjustCalendarHeaders()

<% end %>
