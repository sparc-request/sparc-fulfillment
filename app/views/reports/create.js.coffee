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

$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @report.errors})) %>");
if $("#modal_errors > .alert.alert-danger > p").length == 0
  <% if @reports_params %>
  <% if not @reports_params[:participant_id].blank? %>
  $("#participant_report_<%= @reports_params[:participant_id] %>").data("document_id", "<%= @document.id %>")
  $("#participant_report_<%= @reports_params[:participant_id] %>").attr("document_id", "<%= @document.id %>")
  <% elsif @document.documentable_type == 'Protocol' %>
  $("#study_schedule_report_<%= @reports_params[:protocol_id] %>").data("document_id", "<%= @document.id %>")
  $("#study_schedule_report_<%= @reports_params[:protocol_id] %>").attr("document_id", "<%= @document.id %>")
  <% end %>
  <% end %>
  window.document_id = <%= @document.id %>
  $("#modal_place").modal('hide')
  $('table.documents').bootstrapTable('refresh')
