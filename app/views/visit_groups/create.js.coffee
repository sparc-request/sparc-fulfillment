# Copyright © 2011-2018 MUSC Foundation for Research Development~
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
$("#flashes_container").html("<%= escape_javascript(render('application/flash')) %>")
$("#modal_place").modal 'hide'

# update dropdown to page visit groups
$("#select_for_arm_<%= @arm.id %>").html("<%= escape_javascript(render partial: '/study_schedule/visit_group_page_select', locals: {arm: @arm, page: @current_page.to_i}) %>")
$(".selectpicker").selectpicker()

<% if on_current_page?(@current_page, @visit_group.position) %>
# Overwrite the visit_groups
$(".visit_groups_for_<%= @arm.id %>").html("<%= escape_javascript(render partial: '/study_schedule/visit_groups', locals: { arm: @arm, visit_groups: @visit_groups, tab: @schedule_tab }) %>")
# Overwrite the check columns
$(".check_columns_for_arm_<%= @arm.id %>").html("<%= escape_javascript(render partial: '/study_schedule/check_visit_columns', locals: { visit_groups: @visit_groups, tab: @schedule_tab }) %>")
# Overwrite the visits
<% @arm.line_items.each do |line_item| %>
$(".visits_for_line_item_<%= line_item.id %>").html("<%= escape_javascript(render partial: '/study_schedule/visits', locals: {line_item: line_item, page: @current_page, tab: @schedule_tab}) %>")
<% end %>
<% end %>
<% end %>
