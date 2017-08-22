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

# require 'rails_helper'

# # For reports where:
# # documentable_type = 'Identity'
# feature 'Identity creates a document from the documents page', js: true, enqueue: false do

#   before :each do
#     given_i_am_viewing_the_documents_index_page
#   end

#   context 'of type Invoice Report' do
#     scenario 'and sees the report' do
#       given_i_click_the_create_report_button_of_type 'invoice_report'
#       when_i_fill_in_the_report_of_type 'invoice_report'
#       then_i_will_see_the_new_report_listed 'Invoice report'
#     end
#   end

#   context 'of type Auditing Report' do
#     scenario 'and sees the report' do
#       given_i_click_the_create_report_button_of_type 'auditing_report'
#       when_i_fill_in_the_report_of_type 'auditing_report'
#       then_i_will_see_the_new_report_listed 'Auditing report'
#     end
#   end

#   context 'of type Incomplete Visit Report' do
#     scenario 'and sees the report' do
#       given_i_click_the_create_report_button_of_type 'incomplete_visit_report'
#       when_i_fill_in_the_report_of_type 'incomplete_visit_report'
#       then_i_will_see_the_new_report_listed 'Incomplete visit report'
#     end
#   end

#   context 'of type Project Summary Report' do
#     scenario 'and sees the report' do
#       given_i_click_the_create_report_button_of_type 'project_summary_report'
#       when_i_fill_in_the_report_of_type 'project_summary_report'
#       then_i_will_see_the_new_report_listed 'Project summary report'
#     end
#   end

#   context 'with no documents present' do
#     scenario 'and does not see the counter' do
#       then_i_should_not_see_the_documents_counter
#     end
#   end

#   context 'with documents present' do
#     scenario 'and sees the documents counter increment' do
#       given_i_click_the_create_report_button_of_type 'invoice_report'
#       when_i_fill_in_the_report_of_type 'invoice_report'
#       then_i_should_see_the_documents_counter_increment_to(1)
#       # submit a request for a second report
#       given_i_click_the_create_report_button_of_type 'project_summary_report'
#       when_i_fill_in_the_report_of_type 'project_summary_report'
#       then_i_should_see_the_documents_counter_increment_to(2)
#     end
#   end

#   scenario 'and sees protocols assigned to the them' do
#     given_i_click_the_create_report_button_of_type 'invoice_report'
#     when_i_open_the_organization_dropdown_and_select_an_organization
#     when_i_open_the_protocol_dropdown
#     then_i_should_see_protocols_assigned_to_me
#   end

#   scenario 'and does not see protocols not assigned to them' do
#     ClinicalProvider.destroy_all
#     given_i_click_the_create_report_button_of_type 'invoice_report'
#     then_the_organization_dropdown_should_be_disabled
#   end

#   #Must keep separated or else ClinicalProvider.destroy_all will not work
#   def given_i_am_viewing_the_documents_index_page
#     @protocol = create_and_assign_protocol_to_me

#     visit documents_path
#     wait_for_ajax
#   end

#   def given_i_click_the_create_report_button_of_type report_type
#     find("[data-type='#{report_type}']").click
#     wait_for_ajax
#   end

#   def when_i_fill_in_the_report_of_type report_type
#     if report_type == 'incomplete_visit_report'
#       wait_for_ajax
#       find("input[type='submit']").click
#       wait_for_ajax
#       return
#     end

#     page.execute_script %Q{ $("#start_date").trigger("focus")}
#     page.execute_script %Q{ $("td.day:contains('10')").trigger("click") }
#     page.execute_script %Q{ $("#end_date").trigger("focus")}
#     page.execute_script %Q{ $("td.day:contains('10')").trigger("click") }

#     # close calendar thing, so it's not covering organization dropdown
#     first('.modal-header').click
#     wait_for_ajax

#     if report_type == 'invoice_report'
#       find('button.multiselect').click
#       check(@protocol.organization.name)

#       # close organization dropdown, so it's not covering protocol dropdown
#       first('.modal-header').click
#       wait_for_ajax
#     end

#     protocol_select_id = report_type == 'project_summary_report' ? '#protocol_id' : '#protocol_ids'
#     find("select#{protocol_select_id} + .bootstrap-select button").click
#     wait_for_ajax
#     first('.dropdown-menu.open span.text', text: @protocol.short_title_with_sparc_id).click

#     # close protocol dropdown, so it's not covering 'Request Report' button
#     first('.modal-header').click
#     wait_for_ajax
#     find("input[type='submit']").click
#     wait_for_ajax
#   end

#   def when_i_open_the_protocol_dropdown
#     first('.dropdown-toggle.selectpicker').click
#     wait_for_ajax
#   end

#   def then_the_organization_dropdown_should_be_disabled
#     expect(page).to have_css('button.multiselect.disabled')
#   end

#   def when_i_open_the_organization_dropdown_and_select_an_organization
#     find('button.multiselect').click
#     check(@protocol.organization.name)

#     # close organization dropdown, so it's not covering protocol dropdown
#     first('.modal-header').click
#     wait_for_ajax
#   end

#   def then_i_will_see_the_new_report_listed report_type
#     expect(page).to have_css('table.documents tbody tr td', text: "#{report_type}")
#   end

#   def then_i_should_not_see_the_documents_counter
#     expect(page).to_not have_css(".notiication.identity_report_notifications")
#   end

#   def then_i_should_see_the_documents_counter_increment_to(value)
#     expect(page).to have_css(".notification.identity_report_notifications", text: value)
#   end

#   def then_i_should_see_protocols_assigned_to_me
#     expect(page).to have_css("ul.dropdown-menu.inner.selectpicker li")
#   end

#   def then_i_should_not_see_protocols_not_assigned_to_me
#     expect(page).to_not have_css("ul.dropdown-menu.inner.selectpicker li")
#   end
# end
