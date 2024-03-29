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

$('#study_schedule_buttons').replaceWith("<%= j render 'study_schedule/management/schedule_edit_buttons', protocol: @protocol, tab: @tab %>")

<% @arms_and_pages.each do |arm_id, value| %>
$(".arm-<%= arm_id %>-container").html("<%= j render '/study_schedule/arm', arm: value[:arm], page: value[:page].to_i, tab: @tab %>")
$("#visits_select_for_<%= arm_id %>").selectpicker()
<% end %>

<% if @tab == 'consolidated' %>
$(".study_level_activities_display").html("<%= j render '/study_schedule/study_level_activities', protocol: @protocol %>")
$(".study_level_activities_display").show()
<% else %>
$(".study_level_activities_display").hide()
<% end %>

#Adjust sticky headers
adjustCalendarHeaders()

$('div.study_schedule_container [data-toggle="tooltip"]').tooltip()
